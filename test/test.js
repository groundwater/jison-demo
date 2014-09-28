var espr = require('esprima')
var test = require('tape').test
var gen = require('escodegen').generate
var lang = require('../lang.js')
var opts = {
  format: {
    semicolons: false,
  },
}
var tests = [
  'var x = 1',
  'var y = 1 + 2',
  'var y = 1 + a()',
  'var y = a()',
  'a + b',
  'a() + b()',
  'function a() {\n}',
  'function a() {\n    var y = 1\n}',
  'function a() {\n    var y = a() + b()\n}\nvar x = 1 + 3',
]

tests.forEach(function(line){
  test(line, function(t){
    var l = lang.parse(line)
    var r = espr.parse(line)

    // console.log('got', JSON.stringify(l, null, 2))
    // console.log('exp', JSON.stringify(r, null, 2))

    var s = gen(l, opts)

    t.deepEquals(l, r, 'parse tree equals')
    t.equals(s, line)
    t.end()
  })
})
