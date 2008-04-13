
// Ensei window framework

function openService(uri, title) {
	var successFunc = function(t) { var wid = newWindow(title, uri); setContent(wid, t.responseText); };
	new Ajax.Request(uri, {method:'get', onSuccess:successFunc})
}

function newWindow(title, refreshURI) {
	var wid = Math.round((Math.random() * 1000000000));
	new Insertion.Top('desktop', "<div class='window' id='window" + wid + "'><span class='titlebar' id='title" + wid + "'>" + title + "</span><span class='refreshButton' onclick='refreshWindow("+wid+", \""+refreshURI+"\")'>R</span><span class='renameButton' onclick='setTitle("+wid+", prompt(\"rename to?\"))'>T</span><span class='closeButton' onclick='closeWindow(" + wid + ")'>X</span><div class='content' id='content" + wid + "'></div></div>");
	new Draggable('window' + wid, {handle:'title'+wid});
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
}

function setTitle(wid, title) {
	Element.update("title"+ wid, title);
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