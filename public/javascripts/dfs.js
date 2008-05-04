// for dfs: requires the Prototype.js framework.

var DFS = {};

function DFSApp(appName) {this.appName = appName;} // declare class for Applications
DFSApp.prototype.getSector = function(name) {
	var retItem;
	var request = new Ajax.Request(DFS.server, {method:'get',parameters:{part:'getSector',token:DFS.token,name:name,app:this.appName}, onSuccess:function(t){
		eval("retItem = " + t.responseText);
	}, asynchronous:false, sanitizeJSON:false});
	return retItem;
};
DFSApp.prototype.allData = function(name) {
	var retItem;
	var request = new Ajax.Request(DFS.server, {method:'get',parameters:{part:'dataList',token:DFS.token,app:this.appName}, onSuccess:function(t){
		eval("retItem = " + t.responseText);
	}, asynchronous:false, sanitizeJSON:false});
	return retItem;
};
DFSApp.prototype.sendSector = function(name,value) {
	var retItem;
	var request = new Ajax.Request(DFS.server, {method:'get',parameters:{part:'sendSector',token:DFS.token,name:name,value:Object.toJSON(value),app:this.appName}, onSuccess:function(t){retItem = true;}, asynchronous:false});
	return retItem;
};

DFS.app = function(appName) {
	return new DFSApp(appName);
};
DFS.allApps = function() {
	var retItem;
	var request = new Ajax.Request(DFS.server, {method:'get',parameters:{part:'appList',token:DFS.token}, onSuccess:function(t){
		retItem = eval(t.responseText);
	}, asynchronous:false});
	return retItem;
};
DFS.login = function(server, userName, password) {
	var retItem;
	var request = new Ajax.Request(server, {method:'get',parameters:{part:'login',username:userName,password:password}, onSuccess:function(t){
		DFS.server = server;
		DFS.userName = userName;
		DFS.token = t.responseText;
		retItem = true;
	}, asynchronous:false});
	return retItem;
};
DFS.signup = function(server, userName, password) {
	var retItem;
	var request = new Ajax.Request(server, {method:'get',parameters:{part:'signup',username:userName,password:password}, onSuccess:function(t){
		retItem = true;
	}, asynchronous:false});
	return retItem;
};
DFS.logout = function() {
	var retItem;
	var request = new Ajax.Request(DFS.server, {method:'get',parameters:{part:'logout',token:DFS.token}, onSuccess:function(t){
		DFS.server = null;
		DFS.userName = null;
		DFS.token = null;
		retItem = true;
	}, asynchronous:false});
	return retItem;
};