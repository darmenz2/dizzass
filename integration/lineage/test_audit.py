import unittest
from audit import c_tokens, function_tokens, checked_sha

class SourceFingerprintTests(unittest.TestCase):
    def test_comments(self):
        self.assertEqual(c_tokens('x /* } */ + // (\n y'), ['x', '+', 'y'])
    def test_string_braces(self):
        self.assertEqual(function_tokens('int f(void){puts("}");return 0;}', 'f')[-1], '}')
    def test_escaped_quote(self):
        self.assertIsNotNone(function_tokens(r'int f(){puts("a\"}");}', 'f'))
    def test_character_braces(self):
        self.assertIsNotNone(function_tokens("int f(){return '}';}", 'f'))
    def test_prototype(self):
        self.assertIsNone(function_tokens('int f(void);', 'f'))
    def test_call_is_not_definition(self):
        self.assertIsNone(function_tokens('int g(){ if (f(3)) { return 0; } }', 'f'))
    def test_nested_body(self):
        self.assertEqual(function_tokens('int f(){ if(1) { return 4; } return 2;}', 'f')[-4:], ['return', '2', ';', '}'])
    def test_whitespace_comments(self):
        self.assertEqual(function_tokens('int f(){return 2;}', 'f'), function_tokens('int f ( ) { /*a*/ return 2 ; }', 'f'))
    def test_changed_literal(self):
        self.assertNotEqual(function_tokens('int f(){return 2;}', 'f'), function_tokens('int f(){return 3;}', 'f'))
    def test_duplicate_definition(self):
        with self.assertRaises(ValueError): function_tokens('int f(){} int f(){}', 'f')
    def test_unbalanced(self):
        with self.assertRaises(ValueError): function_tokens('int f(){', 'f')
    def test_operators_remain_distinct(self):
        self.assertNotEqual(c_tokens('x++ + y'), c_tokens('x + + + y'))
        self.assertEqual(c_tokens('x >>= 2; y != 3;'), ['x', '>>=', '2', ';', 'y', '!=', '3', ';'])
    def test_numeric_token_boundaries(self):
        self.assertEqual(c_tokens('0x1fU 0.5f'), ['0x1fU', '0.5f'])
        self.assertNotEqual(c_tokens('0x1fU'), c_tokens('0 x1fU'))
    def test_spliced_comment(self):
        self.assertEqual(c_tokens('x //hidden\\\n still hidden\ny'), ['x', 'y'])
    def test_sha_validation(self):
        self.assertEqual(checked_sha('a' * 40), 'a' * 40)
        for value in ('9f9b64d5', 'A' * 40, '--help', 'x' * 40, 3):
            with self.assertRaises(ValueError): checked_sha(value)

if __name__ == '__main__': unittest.main()
