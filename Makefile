#BUILD SETTINGS
TMP_FOLDER = tmp
BUILD_FOLDER = build

CONFIG_FILE = ${TMP_FOLDER}/config.h
LIB_FOLDER = lib

PYCACHE_SRC_FILE = pycached.py.c
PYCACHE_BUILT_FILE = ${BUILD_FOLDER}/pycached.py

PARSE_TUPLE = ${LIB_FOLDER}/totuple.awk
##################################

SHELL := bash

define newdefine
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "#define $(2) $(3)" >> $(4) || echo "#define $(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

define newdefinestr
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "#define $(2) \"$(3)\"" >> $(4) || echo "#define $(2) \"$$thisset\"" | sed 's/\/$$//g' >> $(4)
endef

define newdefinelist
@echo "When finished press enter on an empty line" ; LIST="" ; while true; do read -p "$(1) > " line ; if [ "$$line" == "" ]; then break; fi; LIST="$${LIST}$${line}|"; done; LIST="$$(sed 's/|$$//g' <<< "$$LIST")" ; echo "#define $(2) \"$$LIST\"" >> $(3)
endef

define getdefine
$$((cpp -P <<< "$$(cat $(1) ; echo "$(2)")") | sed 's/"//g')
endef

define getdefine2dpytuple
@awk -v is2d=1 -f ${PARSE_TUPLE} <<< "$(call getdefine,$(1),$(2))"
endef

all: 
	@echo "usage: make <config | install | clean>"

install: ${PYCACHE_BUILT_FILE}
	[[ ! -d $(call getdefine,${CONFIG_FILE},INSTALLPATH) ]] && mkdir  -p $(call getdefine,${CONFIG_FILE},INSTALLPATH)
	cp -R ${BUILD_FOLDER}/* $(call getdefine,${CONFIG_FILE},INSTALLPATH)

config: ${CONFIG_FILE} ${BUILD_FOLDER}
	cpp -P ${PYCACHE_SRC_FILE} > ${PYCACHE_BUILT_FILE}
	cp *.py ${BUILD_FOLDER}

${CONFIG_FILE}: ${TMP_FOLDER}
	$(call newdefine,Enter web port number,WEBPORT,8080,${CONFIG_FILE})
	$(call newdefinestr,Enter installation path,INSTALLPATH,/opt/pycached,${CONFIG_FILE})
	$(call newdefinestr,Enter cache file name,CACHEFILE,pycache.json,${CONFIG_FILE})
	$(call newdefine,Enter time-to-cache (seconds),CACHETIME,10,${CONFIG_FILE})
	$(call newdefinelist,Enter FIELD_NAME<COMMA>[string|number|boolean],SCHEMALIST,${CONFIG_FILE})
	$(call getdefine2dpytuple,${CONFIG_FILE},SCHEMALIST) | sed 's/\"/\\\"/g' | echo "#define CACHESCHEMA \"$$(cat -)\"" >> ${CONFIG_FILE}

${BUILD_FOLDER}:
	[[ ! -d ${BUILD_FOLDER} ]] && mkdir ${BUILD_FOLDER}


${TMP_FOLDER}:
	[[ ! -d ${TMP_FOLDER} ]] && mkdir ${TMP_FOLDER}

clean:
	rm -rf ${TMP_FOLDER}
	rm -rf ${BUILD_FOLDER}
	rm -rf __pycache__