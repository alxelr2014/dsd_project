import js2py

js1 = """ function allZeros (L) {
  return L.every(function (x) { return x == 0; });
}
 """
res = js2py.eval_js(js1)
print(res([0,0,0,1]))
