
// Ensei window framework

function openService(uri) {
	wid = newWindow("Loading...");
	setContent(wid, new Ajax.Request(uri).responseText);
	return wid;
}

function newWindow(title) {
	wid = Math.round((Math.random() * 1000000000));
	new Insertion.Top('desktop', "<div class='window' id='window" + wid + "'><span class='titlebar' id='title" + wid + "'>" + title + "<span class='closeButton' onclick='closeWindow(" + wid + ")'>X</span></span><div class='content' id='" + wid + "'></div></div>");
	new Draggable('window' + wid, {handle:'title'+wid});
	return wid;
}

function setContent(wid, content) {
	Element.update(""+wid+"", content);
}

function getContent(wid) {
	return document.getElementById(""+wid+"").innerHTML;
}

function closeWindow(wid) {
	Element.remove('window' + wid);
}