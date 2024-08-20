#include "tmp/config.h"

from flask import Flask, make_response, request
from datadef import DataCache
from os.path import exists as path_exists
from json import dumps as dict2str
from ast import literal_eval

typeof = lambda x : type(x).__name__

InstallationPath = INSTALLPATH
CacheFileName = CACHEFILE
CacheSchema = dict(literal_eval(CACHESCHEMA))

with open(f"{InstallationPath}/{CacheFileName}.schema","w") as f:
  f.write(dict2str(CacheSchema))

Cache = DataCache(file=f"{InstallationPath}/{CacheFileName}",cachetime=CACHETIME)

app = Flask(__name__)


@app.route("/", methods=["GET"])
def GetApiHelp():
  pass

@app.route("/query/<query>",methods=["GET"])
def QueryByField(query):
  print(query)
  

@app.route("/insert",methods=["POST"])
def AddData():
  postdata = request.get_json()
  try:
    if typeof(postdata) == 'dict':
      Cache.Insert(postdata)
    elif typeof(postdata) == 'list':
      Cache.InsertMany(postdata)
    else:
      raise Exception("Invalid POST data")
  
  except Exception as e:
    return make_response(str(e),200)

@app.route("/update/<query>",methods=["POST"])
def UpdateData(query):
  pass

@app.route("/delete/<query>",methods=["POST"])
def DeleteData(query=[]):
  pass

@app.route("/addfield",methods=["POST"])
def AddField(fname="",ftype=""):
  pass

app.run("0.0.0.0",WEBPORT)