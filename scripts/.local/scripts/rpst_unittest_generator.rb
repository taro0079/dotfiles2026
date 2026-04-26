def get_test_namespace(target_class_path)
    dirname = File.dirname(target_class_path)
    base_namespace='Tests\app\phpunit\v9\xunit\\'
    converted = dirname.tr('/', '\\')
    base_namespace + converted
end

target_class = ARGV[0]
test_root_dir="tests/app/phpunit/v9/xunit"
test_file_path="#{test_root_dir}/#{target_class}"

content =<<~TEXT
<?php

declare(strict_types=1);

namespace #{get_test_namespace(target_class)};

use Tests\\app\\phpunit\\v9\\abstracts\\test_cases\\TestCaseForXUnit;

class #{File.basename(target_class, '.php')}Test extend TestCaseForXUnit
{
}
TEXT

File.write(test_file_path, content)


