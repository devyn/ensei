
// Ensei window framework

document.windows = new Hash({});

function openService(uri, title) {
	var wid;
	var successFunc = function(t) { wid = newWindow(title, uri); setContent(wid, t.responseText); };
	new Ajax.Request(uri, {method:'get', onSuccess:successFunc, asynchronous:false});
	return wid;
}

function newWindow(title, refreshURI) {
	var wid = Math.round((Math.random() * 1000000000));
	new Insertion.Top('desktop', "<div class='window' id='window" + wid + "'><span class='titlebar' id='title" + wid + "'>" + title + "</span><span class='refreshButton' onclick='refreshWindow("+wid+", \""+refreshURI+"\")'>R</span><span class='renameButton' onclick='setTitle("+wid+", prompt(\"rename to?\"))'>T</span><span class='closeButton' onclick='closeWindow(" + wid + ")'>X</span><div class='content' id='content" + wid + "'></div></div>");
	new Draggable('window' + wid, {handle:'title'+wid});
	document.windows.set(''+wid+'', [refreshURI, title]);
	return wid;
}

function refreshWindow(wid, refreshURI) {
	var successFunc = function(t) { setContent(wid, t.responseText); };
	new Ajax.Request(refreshURI, {method:'get', onSuccess:successFunc});
}

function setContent(wid, content) {
	Element.update("content"+ wid, content);
}

function getContent(wid) {
	return document.getElementById(""+wid+"").innerHTML;
}

function closeWindow(wid) {
	Element.remove('window' + wid);
	document.windows.unset(''+wid+'');
}

function setTitle(wid, title) {
	Element.update("title"+ wid, title);
	var x = document.windows.get(''+wid+'');
	x[1] = title;
	document.windows.set(''+wid+'', x);
}

function getIFrameDocument(id) {
	var oIFrame = document.getElementById(id);
	var oDoc = oIFrame.contentWindow || oIFrame.contentDocument;
	if(oDoc.document) { oDoc = oDoc.document };
	return oDoc;
}

function moveWindow(id, x, y) {
	var oWindow = document.getElementById("window" + id);
	oWindow.style.left = x;
	oWindow.style.top  = y;
}

function fetchWins() {
	var windows = new Array();
	document.windows.keys().each(function(k){
		var v = document.windows.get(k);
		windows = windows.concat([v.concat(document.getElementById('window' + k).style.left, document.getElementById('window' + k).style.top)]);
	});
	return windows;
}

function persistentWindowsSave() {
	DFS.app("ensei").sendSector("persistent", fetchWins());
}

function persistentWindowsLoad() {
	var x = DFS.app("ensei").getSector("persistent");
	if(x) {
		x.each(function(i) {
			if(i) moveWindow(openService(i[0], i[1]), i[2], i[3]);
		});
	}
}

function processLogin() {
	$('loginButton').innerHTML = "Logging in...";
	if (DFS.login("/DFS/client.json", $('username').value, $('password').value) == true) {
		$('loginPart').remove();
		$('desktopPart').style.display = 'inline';
		persistentWindowsLoad();
	} else {
		$('loginButton').innerHTML = "Try again";
		$('password').value = "";
	}
}

function processSignup() {
	$('signupButton').innerHTML = "Signing up...";
	if (DFS.signup("/DFS/client.json", $('username').value, $('password').value) == true) {
		processLogin();
	} else {
		$('signupButton').innerHTML = "Try a different username";
	}
}

function logout() {
	persistentWindowsSave();
	DFS.logout();
	window.location.reload(true);
}