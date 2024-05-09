# %%
import MeCab
wakati = MeCab.Tagger("-Owakati")
wakati.parse("pythonが大好きです").split()

# %%
import CaboCha  
cp = CaboCha.Parser()  
sentence = '猫は道路を渡る犬を見た。'  
print(cp.parseToString(sentence))  
