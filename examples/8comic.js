var page = require('webpage').create();
var system = require('system');
var fs = require('fs');


var website =system.args[1];

//var website ='http://www.yahoo.com.tw';
page.open(website, function () {
    page.evaluate(function(){

    });
	 console.log('comic_title: '+ page.title);
	 console.log(page.content);
    //page.render('export.png');
   // fs.write('1.html', page.content, 'w');
    phantom.exit();
});