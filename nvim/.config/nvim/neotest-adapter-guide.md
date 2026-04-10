# NeoTest カスタムアダプター作成ガイド

## 目次

1. [概要](#概要)
2. [前提知識](#前提知識)
3. [プラグイン構造](#プラグイン構造)
4. [インターフェース仕様](#インターフェース仕様)
5. [各関数の実装](#各関数の実装)
   - [is_test_file](#is_test_file)
   - [root](#root)
   - [filter_dir](#filter_dir)
   - [discover_positions](#discover_positions)
   - [build_spec](#build_spec)
   - [results](#results)
6. [Tree-sitter クエリ](#tree-sitter-クエリ)
7. [結果フォーマット](#結果フォーマット)
8. [neovim への登録](#neovim-への登録)
9. [デバッグ方法](#デバッグ方法)
10. [参考アダプター](#参考アダプター)

---

## 概要

NeoTest はアダプタープラグインを通じて任意のテストフレームワークと連携できます。
アダプターは決められたインターフェースを実装した Lua モジュールで、以下の責務を持ちます。

- テストファイルの識別
- テスト関数・スイートの発見（Tree-sitter による AST 解析）
- テスト実行コマンドの構築
- テスト結果の NeoTest 形式への変換

---

## 前提知識

| 項目 | 内容 |
|---|---|
| 言語 | Lua (Neovim 組み込み) |
| Tree-sitter | テストコードの AST パースに使用 |
| NeoTest API | `neotest.lib` モジュール群 |
| 依存プラグイン | `nvim-neotest/neotest` |

---

## プラグイン構造

```
neotest-myrunner/
├── lua/
│   └── neotest-myrunner/
│       ├── init.lua        # エントリーポイント・アダプター定義
│       ├── parse.lua       # テスト発見ロジック（discover_positions）
│       └── results.lua     # テスト結果パースロジック
└── README.md
```

`init.lua` がアダプターテーブルを返す形にします。
ロジックが複雑な場合は `parse.lua` / `results.lua` に分割して `init.lua` から require します。

---

## インターフェース仕様

アダプターは以下の関数を持つテーブルを返す必要があります。

```lua
local adapter = {}

adapter.name = "neotest-myrunner"

adapter.is_test_file    = function(file_path) end   -- 必須
adapter.root            = function(dir) end          -- 必須
adapter.filter_dir      = function(name, rel_path, root) end  -- 任意
adapter.discover_positions = function(path) end      -- 必須
adapter.build_spec      = function(args) end         -- 必須
adapter.results         = function(spec, result, tree) end    -- 必須

return adapter
```

---

## 各関数の実装

### is_test_file

ファイルパスを受け取り、そのファイルがテスト対象かどうかを `boolean` で返します。

```lua
-- 例: Go (_test.go), TypeScript (.test.ts / .spec.ts), Ruby (*_spec.rb)
adapter.is_test_file = function(file_path)
  return file_path:match("_test%.go$") ~= nil
    or file_path:match("%.test%.[jt]sx?$") ~= nil
    or file_path:match("_spec%.rb$") ~= nil
end
```

**ポイント**
- Lua の `:match()` はパターンマッチ（正規表現ではなく Lua パターン）
- `.` はワイルドカードなので `%.` とエスケープする

---

### root

テストファイルが属するプロジェクトのルートディレクトリを返します。
`neotest.lib` のユーティリティを使うのが最もシンプルです。

```lua
local lib = require("neotest.lib")

-- プロジェクトルートのマーカーファイルを指定
adapter.root = lib.files.match_root_pattern(
  "go.mod",        -- Go
  "package.json",  -- Node.js
  "Cargo.toml",    -- Rust
  ".git"           -- 汎用フォールバック
)
```

---

### filter_dir

テストファイルのスキャン対象から除外するディレクトリを指定します（任意実装）。
`vendor/`, `node_modules/` などを除外してパフォーマンスを向上させます。

```lua
adapter.filter_dir = function(name, rel_path, root)
  -- true を返すとスキャン対象、false で除外
  local exclude = { "vendor", "node_modules", ".git", "dist", "build" }
  for _, dir in ipairs(exclude) do
    if name == dir then return false end
  end
  return true
end
```

---

### discover_positions

テストファイルを解析してテスト位置情報のツリーを返します。
**Tree-sitter クエリ**を使って AST からテスト関数・スイートを抽出します。

```lua
local lib = require("neotest.lib")

adapter.discover_positions = function(path)
  local query = [[
    ;; テストスイート（describe / suite ブロックなど）
    (call_expression
      function: (identifier) @_describe (#eq? @_describe "describe")
      arguments: (arguments
        (string) @namespace.name
      )
    ) @namespace.definition

    ;; テスト関数（it / test ブロックなど）
    (call_expression
      function: (identifier) @_it (#any-of? @_it "it" "test")
      arguments: (arguments
        (string) @test.name
      )
    ) @test.definition
  ]]

  return lib.treesitter.parse_positions(path, query, {
    -- position_id: テストの一意な識別子を生成する関数
    position_id = function(position, namespaces)
      return table.concat(
        vim.tbl_map(function(n) return n.name end, namespaces),
        "::"
      ) .. "::" .. position.name
    end,
  })
end
```

**Tree-sitter クエリのキャプチャ名のルール**

| キャプチャ名 | 役割 |
|---|---|
| `@test.name` | テスト名（文字列） |
| `@test.definition` | テスト全体のノード範囲 |
| `@namespace.name` | スイート名（文字列） |
| `@namespace.definition` | スイート全体のノード範囲 |

---

### build_spec

実際にテストを実行するためのコマンドと設定を返します。
`args.tree` からポジション情報を取得してコマンドを組み立てます。

```lua
adapter.build_spec = function(args)
  local position = args.tree:data()
  local command

  if position.type == "dir" then
    -- ディレクトリ単位で実行
    command = { "mytest", "run", position.path .. "/..." }

  elseif position.type == "file" then
    -- ファイル単位で実行
    command = { "mytest", "run", position.path }

  elseif position.type == "namespace" then
    -- スイート単位で実行
    command = {
      "mytest", "run",
      "--suite", position.name,
      position.path,
    }

  elseif position.type == "test" then
    -- テスト単位で実行
    command = {
      "mytest", "run",
      "--filter", position.name,
      position.path,
    }
  end

  return {
    command = command,
    -- context は results() に引き渡される任意データ
    context = {
      position_id = position.id,
      file = position.path,
    },
  }
end
```

**`position.type` の種類**

| 値 | 説明 |
|---|---|
| `"dir"` | ディレクトリ |
| `"file"` | テストファイル |
| `"namespace"` | テストスイート（describe など） |
| `"test"` | 個別テスト |

---

### results

テスト実行後の出力を解析して、NeoTest が要求する形式の結果テーブルを返します。

```lua
adapter.results = function(spec, result, tree)
  local results = {}

  -- result.output: 出力が書き込まれた一時ファイルのパス
  -- result.code:   終了コード（0 = 成功）
  local output = table.concat(vim.fn.readfile(result.output), "\n")

  -- 例: テストランナーが JSON を出力する場合
  local ok, data = pcall(vim.json.decode, output)
  if not ok then
    -- パース失敗時はファイル全体を failed にする
    results[spec.context.position_id] = {
      status = "failed",
      output = result.output,
    }
    return results
  end

  for _, test in ipairs(data.tests or {}) do
    -- position_id はアダプター内で一意に管理する識別子
    local id = spec.context.file .. "::" .. test.name
    results[id] = {
      status = test.passed and "passed" or "failed",
      short  = test.message,   -- サマリー行（省略可）
      output = result.output,  -- 出力ファイルパス
      -- errors: 失敗時のエラー詳細（省略可）
      errors = test.passed and {} or {
        { message = test.message, line = test.line }
      },
    }
  end

  return results
end
```

**結果テーブルのフィールド**

| フィールド | 型 | 内容 |
|---|---|---|
| `status` | `string` | `"passed"` / `"failed"` / `"skipped"` |
| `short` | `string` | サイン列などに表示される短いメッセージ |
| `output` | `string` | 出力ファイルのパス |
| `errors` | `table[]` | `{ message, line }` のリスト（失敗時） |

---

## Tree-sitter クエリ

### よく使うパターン

#### Go: `TestXxx` 関数

```scheme
(function_declaration
  name: (identifier) @test.name (#match? @test.name "^Test")
) @test.definition
```

#### TypeScript/JavaScript: `describe` / `it` / `test`

```scheme
(call_expression
  function: (identifier) @_func (#any-of? @_func "describe" "suite")
  arguments: (arguments . (string (string_fragment) @namespace.name))
) @namespace.definition

(call_expression
  function: (identifier) @_func (#any-of? @_func "it" "test")
  arguments: (arguments . (string (string_fragment) @test.name))
) @test.definition
```

#### Python: `test_` 関数 / `Test` クラス

```scheme
(class_definition
  name: (identifier) @namespace.name (#match? @namespace.name "^Test")
) @namespace.definition

(function_definition
  name: (identifier) @test.name (#match? @test.name "^test_")
) @test.definition
```

### クエリのデバッグ

Neovim 内で Tree-sitter のパースツリーを確認できます。

```
:InspectTree    " バッファのパースツリーを表示
:EditQuery      " クエリを対話的に試せる
```

---

## 結果フォーマット

テストランナーの出力形式ごとに `results()` の実装が変わります。

### JSON 出力の場合

```lua
-- テストランナーが以下のような JSON を出力する場合
-- { "tests": [{ "name": "FooTest", "passed": true, "message": "" }] }

local data = vim.json.decode(output)
for _, t in ipairs(data.tests) do
  results[id_for(t.name)] = {
    status = t.passed and "passed" or "failed",
    short  = t.message,
  }
end
```

### 行ごとのテキスト出力の場合

```lua
-- "PASS TestFoo" / "FAIL TestBar: some error" のような形式
for line in output:gmatch("[^\n]+") do
  local status, name = line:match("^(PASS|FAIL)%s+(%S+)")
  if status and name then
    results[id_for(name)] = {
      status = status == "PASS" and "passed" or "failed",
    }
  end
end
```

### XML (JUnit) 出力の場合

```lua
-- xml2lua などのライブラリを使うか、パターンマッチで抽出
for name, failure in output:gmatch(
  '<testcase name="([^"]+)"[^>]*>%s*(<failure[^>]*>.-</failure>)%s*</testcase>'
) do
  results[id_for(name)] = {
    status = "failed",
    short  = failure:match('>([^<]+)<'),
  }
end
```

---

## neovim への登録

`lazy.nvim` を使う場合の設定例：

```lua
{
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    -- ローカルパスで読み込む場合
    { dir = "~/dev/neotest-myrunner" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-myrunner"),
        -- オプションを渡す場合
        require("neotest-myrunner")({
          env = { MY_ENV = "value" },
          args = { "--verbose" },
        }),
      },
    })
  end,
}
```

---

## デバッグ方法

### 各関数を単体で確認

```lua
-- Neovim コマンドラインから実行
:lua print(require("neotest-myrunner").is_test_file(vim.fn.expand("%:p")))
:lua print(vim.inspect(require("neotest-myrunner").root(vim.fn.expand("%:p:h"))))

-- テスト発見結果を確認
:lua
local adapter = require("neotest-myrunner")
local tree = adapter.discover_positions(vim.fn.expand("%:p"))
print(vim.inspect(tree))
```

### NeoTest のログを確認

```lua
-- ログレベルを DEBUG に設定
require("neotest").setup({
  log_level = vim.log.levels.DEBUG,
})

-- ログファイルの場所
:lua print(require("neotest.logging").get_filename())
```

### neotest-plenary でアダプターをテスト

`neotest-plenary` を使うと NeoTest アダプター自体を Neovim 内でテストできます。

```lua
-- テストファイル例: tests/init_spec.lua
local adapter = require("neotest-myrunner")

describe("is_test_file", function()
  it("returns true for test files", function()
    assert.is_true(adapter.is_test_file("/path/to/foo_test.go"))
  end)
  it("returns false for non-test files", function()
    assert.is_false(adapter.is_test_file("/path/to/foo.go"))
  end)
end)
```

---

## 参考アダプター

シンプルなものから読み始めることを推奨します。

| リポジトリ | 言語 | 特徴 |
|---|---|---|
| `nvim-neotest/neotest-go` | Go | JSON 出力パース、サブテスト対応 |
| `nvim-neotest/neotest-jest` | JS/TS | 設定ファイル検出、非同期対応 |
| `olimorris/neotest-rspec` | Ruby | シンプルな構造で読みやすい |
| `rouge8/neotest-rust` | Rust | cargo test との連携 |
| `nvim-neotest/neotest-python` | Python | pytest / unittest 両対応 |

公式ドキュメント: https://github.com/nvim-neotest/neotest#supported-runners

---

## PHP / PHPUnit アダプター実装例

### プラグイン構造

```
neotest-phpunit/
├── lua/
│   └── neotest-phpunit/
│       ├── init.lua        # アダプター定義・各モジュールの委譲
│       ├── parse.lua       # discover_positions + build_spec
│       └── results.lua     # JUnit XML パース
└── README.md
```

---

### `init.lua`

```lua
local lib     = require("neotest.lib")
local parse   = require("neotest-phpunit.parse")
local results = require("neotest-phpunit.results")

local adapter = { name = "neotest-phpunit" }

-- テストファイルの識別
-- PHPUnit は *Test.php が慣習。Pest は *.pest.php も対象にする場合は追加
adapter.is_test_file = function(file_path)
  return file_path:match("Test%.php$") ~= nil
    or file_path:match("%.pest%.php$") ~= nil
end

-- プロジェクトルートの特定
-- phpunit.xml > phpunit.xml.dist > composer.json > .git の順で探す
adapter.root = lib.files.match_root_pattern(
  "phpunit.xml",
  "phpunit.xml.dist",
  "composer.json",
  ".git"
)

-- スキャン除外ディレクトリ
-- vendor/ は composer の依存が大量にあるため必ず除外する
adapter.filter_dir = function(name, _rel_path, _root)
  local exclude = { "vendor", "node_modules", ".git", "storage", "bootstrap" }
  for _, dir in ipairs(exclude) do
    if name == dir then return false end
  end
  return true
end

-- テスト発見・コマンド組み立て・結果パースを各モジュールへ委譲
adapter.discover_positions = parse.discover_positions
adapter.build_spec          = parse.build_spec
adapter.results             = results.results

return adapter
```

**ポイント**

| 設定 | 理由 |
|---|---|
| `phpunit.xml` を最優先 | モノレポ内の複数 PHP プロジェクトでも正しいルートを返せる |
| `vendor/` を除外 | composer 依存パッケージ内のテストまでスキャンされるのを防ぐ |
| `*.pest.php` は任意追加 | Pest フレームワークを使わない場合は不要 |

---

### `parse.lua`

```lua
local lib = require("neotest.lib")
local M   = {}

-- ─────────────────────────────────────────
-- Tree-sitter クエリ
-- 対象①: *Test.php 内の TestCase サブクラス → namespace
-- 対象②: test* メソッド                     → test
-- 対象③: @test アノテーション付きメソッド   → test
-- ─────────────────────────────────────────
local QUERY = [[
  ;; クラス定義を namespace として扱う
  ;; 例: class UserTest extends TestCase { ... }
  (class_declaration
    name: (name) @namespace.name
  ) @namespace.definition

  ;; test プレフィックスのメソッド
  ;; 例: public function testCanLogin() { ... }
  (method_declaration
    name: (name) @test.name (#match? @test.name "^test")
  ) @test.definition

  ;; /** @test */ アノテーション付きメソッド
  ;; PHPDoc コメントが直前にある method_declaration を対象にする
  (comment) @_doc
  (#match? @_doc "@test")
  (method_declaration
    name: (name) @test.name
  ) @test.definition
]]

-- discover_positions
M.discover_positions = function(path)
  return lib.treesitter.parse_positions(path, QUERY, {
    -- position_id: namespace::testName 形式で一意なIDを生成
    position_id = function(position, namespaces)
      local parts = vim.tbl_map(function(n) return n.name end, namespaces)
      table.insert(parts, position.name)
      return table.concat(parts, "::")
    end,
    nested_tests = false,
  })
end

-- build_spec
M.build_spec = function(args)
  local pos  = args.tree:data()
  local root = args.tree:root():data().path

  -- vendor/bin/phpunit を優先、なければグローバルの phpunit
  local binary = root .. "/vendor/bin/phpunit"
  if vim.fn.executable(binary) == 0 then
    binary = "phpunit"
  end

  -- phpunit.xml / phpunit.xml.dist が存在すれば --configuration で渡す
  local config_file
  for _, name in ipairs({ "phpunit.xml", "phpunit.xml.dist" }) do
    local candidate = root .. "/" .. name
    if vim.fn.filereadable(candidate) == 1 then
      config_file = candidate
      break
    end
  end

  -- 結果を受け取るための JUnit XML 一時ファイル
  local report = vim.fn.tempname() .. ".xml"

  -- ベースコマンド
  local cmd = { binary }
  if config_file then
    vim.list_extend(cmd, { "--configuration", config_file })
  end
  vim.list_extend(cmd, { "--log-junit", report })

  -- position.type ごとにフィルタを付加
  if pos.type == "dir" then
    table.insert(cmd, pos.path)

  elseif pos.type == "file" then
    table.insert(cmd, pos.path)

  elseif pos.type == "namespace" then
    -- クラス名でフィルタ（例: --filter UserTest）
    vim.list_extend(cmd, { "--filter", pos.name, pos.path })

  elseif pos.type == "test" then
    -- メソッド名でフィルタ
    -- サブテスト（データプロバイダ）は "testMethod #1" のような名前になるため前方一致パターンにする
    vim.list_extend(cmd, {
      "--filter", string.format("^%s(::.+)?$", pos.name),
      pos.path,
    })
  end

  return {
    command = cmd,
    context = {
      position_id = pos.id,
      file        = pos.path,
      report      = report,   -- results.lua で XML を読むために渡す
    },
  }
end

return M
```

**Tree-sitter クエリのキャプチャ**

| キャプチャ | 対象 |
|---|---|
| `@namespace.name` / `@namespace.definition` | クラス定義 |
| `@test.name` / `@test.definition` | `test*` メソッド・`@test` アノテーション付きメソッド |
| `@_doc`（補助） | `@_` プレフィックスで位置情報に含まれない |

**`build_spec` の工夫**

| 処理 | 理由 |
|---|---|
| `vendor/bin/phpunit` を優先 | プロジェクトごとにバージョンが異なるため |
| `phpunit.xml` の自動検出 | 設定ファイルがないとブートストラップが効かない場合がある |
| `--filter` を正規表現に | データプロバイダ付きテスト（`testMethod #1`）にも対応するため |
| `report` を `context` に格納 | `results.lua` で JUnit XML のパスとして使用 |

---

### `results.lua`

```lua
local M = {}

-- JUnit XML の構造（PHPUnit 出力例）
-- <testsuites>
--   <testsuite name="UserTest" file="/path/UserTest.php">
--     <testcase name="testCanLogin" class="UserTest" file="..." line="12" time="0.01"/>
--     <testcase name="testCanLogout" ...>
--       <failure type="..." message="...">詳細メッセージ</failure>
--     </testcase>
--     <testcase name="testSkipped" ...>
--       <skipped/>
--     </testcase>
--     <testcase name="testError" ...>
--       <error type="Exception" message="...">スタックトレース</error>
--     </testcase>
--   </testsuite>
-- </testsuites>

-- XML から全 testcase ブロックを抽出するヘルパー
local function parse_xml(xml)
  local cases = {}

  -- 自己終了タグ <testcase ... /> → 子要素なし → passed
  for block in xml:gmatch("<testcase(.-)/>") do
    local name  = block:match("name=\"(.-)\"")
    local class = block:match("class=\"(.-)\"")
    local line  = block:match("line=\"(.-)\"")
    if name then
      table.insert(cases, {
        name   = name,
        class  = class,
        line   = tonumber(line),
        status = "passed",
      })
    end
  end

  -- 開始・終了タグ <testcase ...>...</testcase> → 子要素で status を判定
  for block in xml:gmatch("<testcase(.-)>(.-)</testcase>") do
    local name  = block:match("name=\"(.-)\"")
    local class = block:match("class=\"(.-)\"")
    local line  = block:match("line=\"(.-)\"")

    local status, message
    local failure = block:match("<failure[^>]*>(.-)</failure>")
    local error_  = block:match("<error[^>]*>(.-)</error>")
    local skipped = block:match("<skipped")

    if failure then
      status  = "failed"
      message = failure:match("^%s*(.-)%s*$")
    elseif error_ then
      status  = "failed"
      message = error_:match("^%s*(.-)%s*$")
    elseif skipped then
      status  = "skipped"
    else
      status  = "passed"
    end

    if name then
      table.insert(cases, {
        name    = name,
        class   = class,
        line    = tonumber(line),
        status  = status,
        message = message,
      })
    end
  end

  return cases
end

-- position_id を組み立てるヘルパー（parse.lua の生成ルールに合わせる）
local function make_id(file, class, test_name)
  if class and class ~= "" then
    return file .. "::" .. class .. "::" .. test_name
  end
  return file .. "::" .. test_name
end

M.results = function(spec, result, _tree)
  local res = {}

  -- JUnit XML レポートを読み込む
  local report_path = spec.context.report
  if not report_path or vim.fn.filereadable(report_path) == 0 then
    -- レポートが存在しない場合（実行自体が失敗した場合など）
    res[spec.context.position_id] = {
      status = "failed",
      output = result.output,
      errors = {
        { message = "phpunit failed to produce a report. exit code: " .. result.code }
      },
    }
    return res
  end

  local xml   = table.concat(vim.fn.readfile(report_path), "\n")
  local cases = parse_xml(xml)

  if vim.tbl_isempty(cases) then
    res[spec.context.position_id] = {
      status = "failed",
      output = result.output,
      errors = { { message = "Could not parse JUnit XML report." } },
    }
    return res
  end

  for _, case in ipairs(cases) do
    local id = make_id(spec.context.file, case.class, case.name)
    res[id] = {
      status = case.status,
      output = result.output,
      short  = case.message,
      errors = (case.status == "failed" and case.message) and {
        {
          message = case.message,
          line    = case.line and (case.line - 1) or nil,  -- 0-indexed に変換
        }
      } or nil,
    }
  end

  -- 一時ファイルを削除
  vim.fn.delete(report_path)

  return res
end

return M
```

**`parse_xml` の処理フロー**

```
<testcase .../> （自己終了）    → passed
<testcase ...>
  <failure>...</failure>       → failed  (テストアサーション失敗)
  <error>...</error>           → failed  (例外・致命的エラー)
  <skipped/>                   → skipped (markTestSkipped())
</testcase>
```

**返り値フィールド**

| フィールド | 型 | 表示場所 |
|---|---|---|
| `status` | `"passed"` / `"failed"` / `"skipped"` | ガター・サマリー |
| `short` | failure メッセージの1行目 | サイン列のツールチップ |
| `output` | 生の標準出力ファイルパス | NeoTest 出力ウィンドウ |
| `errors[].message` | 詳細なエラーメッセージ | diagnostics / quickfix |
| `errors[].line` | エラー行番号（0-indexed） | インラインエラー表示 |

> `xml2lua` などの外部ライブラリを使わず Lua パターンマッチのみで実装しているため依存なしで動作します。CDATA セクションを含む複雑な XML が出力される場合は `xml2lua` の導入を検討してください。

---

### データの流れ（まとめ）

```
PHPUnit 実行（build_spec で組み立てたコマンド）
    ↓
--log-junit /tmp/xxx.xml  に JUnit XML を書き出す
    ↓
results(spec, result, tree) が呼ばれる
    ↓
spec.context.report  → XML ファイルパス
result.output        → 標準出力の一時ファイルパス
result.code          → 終了コード
    ↓
parse_xml() で <testcase> を全件抽出
    ↓
{ [position_id] = { status, short, output, errors } } を返す
```
