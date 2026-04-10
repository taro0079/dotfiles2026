("<!--{" @punctuation.bracket)
("}-->" @punctuation.bracket)

("<!--{if" @keyword.conditional)
("<!--{elseif" @keyword.conditional)
("<!--{else}-->" @keyword.conditional)
("<!--{/if}-->" @keyword.conditional)
("<!--{foreach" @keyword.repeat)
("<!--{/foreach}-->" @keyword.repeat)
; ("as" @keyword)

(php) @variable
; (variable) @variable

(parameter
  name: (attribute_name) @property
  value: (attribute_value) @string)

(string_double) @string
(string_single) @string
(array_value) @punctuation.bracket
