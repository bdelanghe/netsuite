/**
 * Created with IntelliJ IDEA.
 * User: lmarkovic
 * Date: 11/21/13
 * Time: 1:44 PM
 * To change this template use File | Settings | File Templates.
 */

function createHeader(browserType,recordID,relativepathToRoot){
    var resultHtml="";

    var mode='letter';
    var sortMode = 'label';

    var actualDomain=null;

    if (browserType=='schema')
    {
        var alphaMap=schemaAlphaMap;
        var recordName= objectIDMap[recordID]['schemaName'];

        var urlMode=getURLParameter('mode');
        if (urlMode=='package')
        {
            mode=urlMode;
        }

    }
    else if (browserType=='script')
    {
        var alphaMap=scriptAlphaMap;
        var recordName= objectIDMap[recordID]['scriptLabel'];
        // var changeMap = scriptChangeMap;
        var urlMode=getURLParameter('mode');
        if (urlMode=='new')
        {
            mode=urlMode;
        }
    }
    else if (browserType=='odbc')
    {
        var alphaMap=odbcAlphaMap;
        var recordName= objectIDMap[recordID]['odbcName'];
        var urlMode=getURLParameter('mode');
        if (urlMode=='domain')
        {
            mode=urlMode;
            actualDomain = encodeURIComponent(getURLParameter('domain'));
        }

    }
    else if (browserType=='analytics')
    {
        var urlMode=getURLParameter('mode');
        var alphaMap=analyticsAlphaMapLabel;
        var recordName= objectIDMap[recordID]['analyticsLabel'];
        var urlMode=getURLParameter('mode');
        if (urlMode == 'id') {
            sortMode = 'id';
             alphaMap = analyticsAlphaMap;
             recordName = objectIDMap[recordID]['analyticsName'];
        }
    }

    resultHtml = resultHtml.concat('<script>\n');
    resultHtml = resultHtml.concat('$(function() {\n');
    resultHtml = resultHtml.concat('$( "#alphabetrecordswitch" ).buttonset();\n');
    resultHtml = resultHtml.concat('$( ".packagesbuttons" ).buttonset();\n');
    if (browserType == 'analytics'){
        resultHtml = resultHtml.concat('$( "#analyticssort" ).buttonset();\n');
        resultHtml = resultHtml.concat('$( ".packagesbuttons" ).buttonset();\n');

    }

    resultHtml = resultHtml.concat('$( "#packagestabs" ).tabs();\n');

    if (browserType=='schema' )
        resultHtml = resultHtml.concat('$(\'#schemabrowserswitch\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\');\n')
    else
        resultHtml = resultHtml.concat('$(\'#scriptbrowserswitch\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\');\n');
    resultHtml = resultHtml.concat('});\n');
    resultHtml = resultHtml.concat('</script>\n');

    var divName ='mainheader';
    if (mode=='package')
    {
        divName ='packagemainheader';
    }

    resultHtml = resultHtml.concat('<div id="',divName,'" class="ui-widget-header ui-corner-all">\n');

    resultHtml = resultHtml.concat('<div id="menubar" >\n');
    resultHtml = resultHtml.concat('<span id="browsertypeswitch">\n');
    resultHtml = resultHtml.concat('<div id="browsertypetabs">\n');
    resultHtml = resultHtml.concat('<ul>\n');
    var hrefLink='';
    var indexactivetab=0;
    var hrefschematab='';
    var hrefscripttab='';
    var hrefodbctab='';
    var hrefanalyticstab='';

    if (browserType=='schema')
    {
        indexactivetab=0;
        hrefLink = '#browsertab';
    }
    else
    {
        hrefLink = '#schematab';
        if((objectIDMap[recordID]['inSchema']=='T')&&(objectIDMap[recordID]['ignore4schema']!='T'))
        {
            hrefschematab = hrefschematab.concat(relativepathToRoot,'/schema/record/',recordID.split('__')[1],'.html\n');
        }
        else
        {
            hrefschematab = hrefschematab.concat(relativepathToRoot,'/schema/index.html\n');
        }
    }
    resultHtml = resultHtml.concat('<li id="schemali"><a  href="',hrefLink,'">Schema Browser</a></li>\n');

    hrefLink='';
    if (browserType=='script')
    {
        indexactivetab=1;
        hrefLink = '#browsertab';

    }
    else
    {
        hrefLink = '#scripttab';
        if((objectIDMap[recordID]['inScript']=='T')&&(objectIDMap[recordID]['ignore4script']!='T'))
        {
            hrefscripttab = hrefscripttab.concat(relativepathToRoot,'/script/record/',recordID.split('__')[1],'.html\n');
        }
        else
        {
            hrefscripttab = hrefscripttab.concat(relativepathToRoot,'/script/index.html\n');
        }
    }
    resultHtml = resultHtml.concat('<li id="scriptli"><a  href="',hrefLink,'">Records Browser</a></li>\n');

    hrefLink='';
    if (browserType=='odbc')
    {
        indexactivetab=2;
        hrefLink = '#browsertab';
    }
    else
    {
        hrefLink = '#odbctab';
        if((objectIDMap[recordID]['inOdbc']=='T'))
        {
            hrefodbctab = hrefodbctab.concat(relativepathToRoot,'/odbc/record/',recordID.split('__')[1],'.html\n');
        }
        else
        {
            hrefodbctab = hrefodbctab.concat(relativepathToRoot,'/odbc/index.html\n');
        }
    }
    resultHtml = resultHtml.concat('<li id="odbcli"><a  href="',hrefLink,'">Connect Browser</a></li>\n');
    hrefLink='';
    if (browserType=='analytics')
    {
        indexactivetab=3;
        hrefLink = '#browsertab';
    }
    else
    {
        hrefLink = '#analyticstab';
        if((objectIDMap[recordID]['inAnalytics']=='T'))
        {
            hrefanalyticstab = hrefanalyticstab.concat(relativepathToRoot,'/analytics/record/',recordID.split('__')[1],'.html\n');
        }
        else
        {
            hrefanalyticstab = hrefanalyticstab.concat(relativepathToRoot,'/analytics/index.html\n');
        }
    }

    resultHtml = resultHtml.concat('<li id="analyticscli"><a  href="',hrefLink,'">Analytics Browser</a></li>\n');

    resultHtml = resultHtml.concat('</ul>\n');

    resultHtml = resultHtml.concat('<div id="schematab" style="visibility: hidden;display: none;"><a href="',hrefschematab,'">go to link</a></div>\n');
    resultHtml = resultHtml.concat('<div id="scripttab" style="visibility: hidden; display: none;"><a href="',hrefscripttab,'">go to link</a></div>\n');
    resultHtml = resultHtml.concat('<div id="odbctab" style="visibility: hidden; display: none;"><a href="',hrefodbctab,'">go to link</a></div>\n');
    resultHtml = resultHtml.concat('<div id="analyticstab" style="visibility: hidden; display: none;"><a href="',hrefanalyticstab,'">go to link</a></div>\n');

    if (browserType=='analytics')
    {
     resultHtml = resultHtml.concat('<div id="sortselect" aria-labelledby="ui-id-422" class="ui-tabs-panel ui-widget-content ui-corner-bottom" role="tabpanel" aria-expanded="true" aria-hidden="false">\n');
     resultHtml = resultHtml.concat('<span id="analyticssort" class="ui-buttonset">\n');

        resultHtml = resultHtml.concat('<button id="sortlabel" onclick="window.location.href=\'',relativepathToRoot,'/analytics/record/',recordID.split('__')[1],'.html\'"> Sort by Label</button>\n');
        if(sortMode != 'id') {
            resultHtml = resultHtml.concat('<script>\n');
            resultHtml = resultHtml.concat('$(function(){ $(\'#sortlabel\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\'); });\n');
            resultHtml = resultHtml.concat('</script>\n');
        }

        resultHtml = resultHtml.concat('<button id="sortid" onclick="window.location.href=\'',relativepathToRoot,'/analytics/record/',recordID.split('__')[1],'.html?mode=id\'">Sort by Id</button>\n');

        if(sortMode == 'id')
         {
             resultHtml = resultHtml.concat('<script>\n');
             resultHtml = resultHtml.concat('$(function(){ $(\'#sortid\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\'); });\n');
             resultHtml = resultHtml.concat('</script>\n');
         }
        resultHtml = resultHtml.concat('</span>\n');
         resultHtml = resultHtml.concat('</div>\n');
    }

    resultHtml = resultHtml.concat('<div id="browsertab">\n');

    resultHtml = resultHtml.concat('<span id="alphabetrecordswitch">\n');
    if (browserType == 'odbc')
        resultHtml = resultHtml.concat('Select a table alphabetically: <br />');
    // From https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/keys
    if (!Object.keys) {
       Object.keys = (function() {
          'use strict';
          var hasOwnProperty = Object.prototype.hasOwnProperty,
          hasDontEnumBug = !({ toString: null }).propertyIsEnumerable('toString'),
          dontEnums = [
          'toString',
          'toLocaleString',
          'valueOf',
          'hasOwnProperty',
          'isPrototypeOf',
          'propertyIsEnumerable',
          'constructor'
          ],
          dontEnumsLength = dontEnums.length;

       return function(obj) {
          if (typeof obj !== 'object' && (typeof obj !== 'function' || obj === null)) {
             throw new TypeError('Object.keys called on non-object');
          }

          var result = [], prop, i;

          for (prop in obj) {
             if (hasOwnProperty.call(obj, prop)) {
                result.push(prop);
             }
          }

          if (hasDontEnumBug) {
             for (i = 0; i < dontEnumsLength; i++) {
                if (hasOwnProperty.call(obj, dontEnums[i])) {
                   result.push(dontEnums[i]);
                }
             }
          }
          return result;
       };
       }());
    }
    var letters = Object.keys(alphaMap);

    // Production steps of ECMA-262, Edition 5, 15.4.4.18
    // Reference: http://es5.github.io/#x15.4.4.18
    if (!Array.prototype.forEach)  {

       Array.prototype.forEach = function(callback, thisArg) {

          var T, k;

          if (this == null) {
             throw new TypeError(' this is null or not defined');
          }

          // 1. Let O be the result of calling ToObject passing the |this| value as the argument.
          var O = Object(this);

          // 2. Let lenValue be the result of calling the Get internal method of O with the argument "length".
          // 3. Let len be ToUint32(lenValue).
          var len = O.length >>> 0;

          // 4. If IsCallable(callback) is false, throw a TypeError exception.
          // See: http://es5.github.com/#x9.11
          if (typeof callback !== "function") {
             throw new TypeError(callback + ' is not a function');
          }

          // 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
          if (arguments.length > 1) {
             T = thisArg;
          }

          // 6. Let k be 0
          k = 0;

          // 7. Repeat, while k < len
          while (k < len) {

             var kValue;

             // a. Let Pk be ToString(k).
             //   This is implicit for LHS operands of the in operator
             // b. Let kPresent be the result of calling the HasProperty internal method of O with argument Pk.
             //   This step can be combined with c
             // c. If kPresent is true, then
             if (k in O) {

                // i. Let kValue be the result of calling the Get internal method of O with argument Pk.
                kValue = O[k];

                // ii. Call the Call internal method of callback with T as the this value and
                // argument list containing kValue, k, and O.
                callback.call(T, kValue, k, O);
             }
             // d. Increase k by 1.
             k++;
          }
          // 8. return undefined
       };
    }
    letters.forEach(function(letter){
        resultHtml = resultHtml.concat('<button id="letter',letter,'" name="alphabetswitch"   onclick="window.location.href=\'',relativepathToRoot,
                                       '/',browserType,'/record/',alphaMap[letter][0].split('__')[1],'.html');
        if (sortMode == 'id') {
            resultHtml = resultHtml.concat('?mode=id');
        }
        resultHtml = resultHtml.concat('\'">',letter,'</button>\n');
        if(recordName.charAt(0).toUpperCase()==letter)
        {
            resultHtml = resultHtml.concat('<script>\n');
            if (mode=='letter')
            {
                resultHtml = resultHtml.concat('$(function(){ $(\'#letter',letter,'\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\'); });\n');
            }
            else
            {
                if (browserType != 'odbc')
                    resultHtml = resultHtml.concat('$(function() {$(\'#letter',letter,'\').addClass(\'ui-priority-secondary\');  });\n');
            }
            resultHtml = resultHtml.concat('</script>\n');
        }
    });



    if ((browserType=='script') && !isEmpty(scriptNewList))
    {
        var recID = 0 ;//scriptNewList[0];
        {
            if(scriptNewList.hasOwnProperty(recID))
            {
                resultHtml = resultHtml.concat('<div id="changesswitch" class="ui-widget">\n');
                resultHtml = resultHtml.concat('<button id="newsswitch" name="newsswitch"    onclick="window.location.href=\'',relativepathToRoot,'/',browserType,'/record/',
                    scriptNewList[recID].split('__')[1],'.html?mode=new\'"> New records and fields</button>');

                if(mode=='new')
                {
                    resultHtml = resultHtml.concat('<script>');
                    resultHtml = resultHtml.concat('$(function() {');
                    resultHtml = resultHtml.concat('$(\'#newsswitch\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\');');
                    resultHtml = resultHtml.concat('});');
                    resultHtml = resultHtml.concat('</script>');
                }

                resultHtml = resultHtml.concat('</div>\n');
            }
        }
    }

    resultHtml = resultHtml.concat('</span>\n');
    if (browserType=='schema')// && mode=='package')
    {
        var selectedPackageTxt="";
        var selectedPackageVal="";
        resultHtml = resultHtml.concat('<div id="packagesswitch" class="ui-widget">\n');
        resultHtml = resultHtml.concat('<select id="packagesselect">\n');

        resultHtml = resultHtml.concat('<option value="" >Select package...</option>\n');
        for (var package in schemaPackageMap)
        {
            if(schemaPackageMap.hasOwnProperty(package))
            {
                resultHtml = resultHtml.concat('<optgroup label="',package,'"name="packagegrp_',package,'">\n');
                for (var sourceFile in schemaPackageMap[package])
                {
                    if(schemaPackageMap[package].hasOwnProperty(sourceFile))
                    {
                        var optClass='';
                        if(objectIDMap[recordID]['schemaPackage']==package && objectIDMap[recordID]['schemaXSDFile']==sourceFile)
                        {
                            optClass='class="selectedPackageItem"';
                            selectedPackageTxt=sourceFile;
                            selectedPackageVal="package"+package+sourceFile;
                        }
                        resultHtml = resultHtml.concat('<option value="package',package,sourceFile,'" ',optClass,' href="',relativepathToRoot,'/',browserType,'/index_',package,'_',sourceFile,'.html" >',sourceFile,'</option>\n');
                    }
                }
                resultHtml = resultHtml.concat('</optgroup>\n');
            }
        }

        resultHtml = resultHtml.concat('</select>\n');
        resultHtml = resultHtml.concat('</div>\n');
        resultHtml = resultHtml.concat('<script>\n');
        resultHtml = resultHtml.concat('$( "#packagesselect" ).combobox_with_optgroup().val("',selectedPackageVal,'");\n');
        resultHtml = resultHtml.concat('$( "#packagesselect" ).combobox_with_optgroup().combobox_with_optgroup("getInput").val("',selectedPackageTxt,'");\n');
        if (mode=='letter')
        {
            resultHtml = resultHtml.concat('$(function() {$(\'#packagesswitch\').find(\'input\').addClass(\'ui-priority-secondary\');  });\n');
        }
        else
        {
            resultHtml = resultHtml.concat('$(function(){ $(\'#packagesswitch\').find(\'input\').addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\'); });\n');
        }

        resultHtml = resultHtml.concat('</script>\n');
    }

    if ((browserType=='odbc') && !isEmpty(odbcDomainMap))
    {
        var selectedPackageTxt="";
        var selectedPackageVal="";
        resultHtml = resultHtml.concat('<div id="packagesswitch" class="ui-widget">\n');
        resultHtml = resultHtml.concat('or select a domain: <br />');
        resultHtml = resultHtml.concat('<select id="packagesselect">\n');

        resultHtml = resultHtml.concat('<option value="" >Select package...</option>\n');
        for (var domain in odbcDomainMap)
        {
            if(odbcDomainMap.hasOwnProperty(domain))
            {
                resultHtml = resultHtml.concat('<option value="domain',domain,'" ',optClass,' href="',relativepathToRoot,'/',browserType,'/index_',domain,'.html" >',cap_first(domain),'</option>\n');

                if (actualDomain != null)
                    selectedPackageTxt = actualDomain;
                else
                    selectedPackageTxt = "Select domain";
            }
        }

        resultHtml = resultHtml.concat('</select>\n');
        resultHtml = resultHtml.concat('</div>\n');
        resultHtml = resultHtml.concat('<script>\n');
        resultHtml = resultHtml.concat('$( "#packagesselect" ).combobox_with_optgroup().combobox_with_optgroup("getInput").val("',cap_first(selectedPackageTxt),'");\n');

        if (mode=='letter')
        {
            resultHtml = resultHtml.concat('$(function() {$(\'#packagesswitch\').find(\'input\').addClass(\'ui-priority-secondary\');  });\n');
        }
        else
        {
            resultHtml = resultHtml.concat('$(function(){ $(\'#packagesswitch\').find(\'input\').addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\'); });\n');
        }

        resultHtml = resultHtml.concat('</script>\n');
    }

    resultHtml = resultHtml.concat('</div>\n'); //browsertab
    resultHtml = resultHtml.concat('</div>\n'); //browsertypetabs

    resultHtml = resultHtml.concat('<script>\n');
    resultHtml = resultHtml.concat('$( "#browsertypetabs" ).tabs({active:',indexactivetab,'});\n');
    resultHtml = resultHtml.concat('$( "#browsertypetabs" ).tabs({active:',indexactivetab,'});\n');

    if (browserType == 'odbc')
        resultHtml = resultHtml.concat('$( ".custom-combobox .custom-combobox-toggle .ui-button-text" ).html("&#x25bd;");');

    resultHtml = resultHtml.concat('$( "#browsertypetabs" ).on( "tabsbeforeactivate", function( event, ui ) {\n');
    resultHtml = resultHtml.concat('  if(ui.newPanel.attr("id")=="schematab") {window.location.href =ui.newPanel.find("a:first").attr("href");}\n');
    resultHtml = resultHtml.concat('  if(ui.newPanel.attr("id")=="scripttab") {window.location.href =ui.newPanel.find("a:first").attr("href");}\n');
    resultHtml = resultHtml.concat('  if(ui.newPanel.attr("id")=="odbctab") {window.location.href =ui.newPanel.find("a:first").attr("href");}\n');
    resultHtml = resultHtml.concat('  if(ui.newPanel.attr("id")=="analyticstab") {window.location.href =ui.newPanel.find("a:first").attr("href");}\n');
    resultHtml = resultHtml.concat('} );\n');
    resultHtml = resultHtml.concat('</script>\n');

    resultHtml = resultHtml.concat('</span>\n');

    resultHtml = resultHtml.concat('</div>\n');
    resultHtml = resultHtml.concat('</div>\n');
    if (browserType == 'odbc') {
        resultHtml = resultHtml.concat('<br><br><div class="th_imp">' +
            '<b>The NetSuite.com data source is no longer supported in 2025.1 and will be removed in 2026.1.</b><br>' +
            'You should use the NetSuite2.com data source when working with SuiteAnalytics Connect to avoid any disruptions.<br>' +
            'For more information, see ' +
            '<a href="https://system.netsuite.com/app/help/helpcenter.nl?fid=article_0405125116.html" target="_blank" class="keepDomain">NetSuite2.com Data Source and Connect NetSuite.com End of Support</a>.</div><br><br>');
    }
    return resultHtml;
}

function createLeftPanel(browserType,recordID,relativepathToRoot){
    var resultHtml="";

    var mode='letter';
    var actualDomain = null;
    var sortMode = 'original';
    if (browserType=='schema')
    {
        var alphaMap=schemaAlphaMap;
        var nametag='schemaName';
        var nametag2='schemaName';
        var urlMode=getURLParameter('mode');
        if (urlMode=='package')
        {
            mode=urlMode;
        }
    }
    else if (browserType=='script')
    {
        var alphaMap=scriptAlphaMap;
        var nametag='scriptLabel';
        var nametag2='scriptName';
        var urlMode=getURLParameter('mode');
        if (urlMode=='new')
        {
            mode=urlMode;
        }
    }
    else if (browserType=='odbc')
    {
        var alphaMap=odbcAlphaMap;
        var nametag='odbcName';
        var nametag2='odbcName';
        var urlMode=getURLParameter('mode');
        if (urlMode=='domain')
        {
            mode=urlMode;
            actualDomain = encodeURIComponent(getURLParameter('domain'));
        }
    }
    else if (browserType=='analytics')
    {
        var alphaMap=analyticsAlphaMapLabel;
        var nametag2='analyticsName';
        var nametag='analyticsLabel';
        var urlMode=getURLParameter('mode');
        if (urlMode == 'id') {
            sortMode = 'id';
            alphaMap = analyticsAlphaMap;
            nametag = 'analyticsName';
            nametag2 = 'analyticsLabel';
        }

    }

    if(mode=='letter')
    {
        var letter = objectIDMap[recordID][nametag].toUpperCase().charAt(0);
        // if(letter == "@")
        //     letter = "@NEW";
        // else if(letter == "_")
        //     letter = "_CHANGED";


        resultHtml = resultHtml.concat('<script>');
        resultHtml = resultHtml.concat('$(function() {');
        resultHtml = resultHtml.concat('        $(".objectlistbuttons").buttonsetv();');
        resultHtml = resultHtml.concat('});');
        resultHtml = resultHtml.concat('</script>');

        resultHtml = resultHtml.concat('<div id="leftpanelmain" >');
        resultHtml = resultHtml.concat('<div id="leftpanelrecord" class="ui-corner-all" >');
        resultHtml = resultHtml.concat('<span id="recordlist" class="objectlistbuttons">');
        for (var recID in alphaMap[letter])
        {
            if(alphaMap[letter].hasOwnProperty(recID))
            {
                var recordName=objectIDMap[alphaMap[letter][recID]][nametag];
                if (recordName==undefined)
                {
                    recordName=objectIDMap[alphaMap[letter][recID]][nametag2];
                }
                recordName=recordName.charAt(0).toUpperCase()+recordName.substring(1);
                resultHtml = resultHtml.concat('<button id="',alphaMap[letter][recID],'" name="recordswitch"    onclick="window.location.href=\'',relativepathToRoot,'/',browserType,'/record/',
                                               alphaMap[letter][recID].split('__')[1],'.html');
                if (sortMode == 'id') {
                    resultHtml = resultHtml.concat('?mode=id');
                }

                resultHtml = resultHtml.concat('\'">',recordName,'</button>');
                if(recordID==alphaMap[letter][recID])
                {
                    resultHtml = resultHtml.concat('<script>');
                    resultHtml = resultHtml.concat('$(function() {');
                    resultHtml = resultHtml.concat('$(\'#',alphaMap[letter][recID],'\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\');');
                    resultHtml = resultHtml.concat('});');
                    resultHtml = resultHtml.concat('</script>');
                }
            }
        }
        resultHtml = resultHtml.concat('</span>');
        resultHtml = resultHtml.concat('</div>');
        resultHtml = resultHtml.concat('</div>');
    }
    else if (mode=='package')   //package
    {
        resultHtml = resultHtml.concat('<script>');
        resultHtml = resultHtml.concat('$(function() {');
        resultHtml = resultHtml.concat('        $(".objectlistbuttons").buttonsetv();');
        resultHtml = resultHtml.concat('        $( "#leftpaneltabs" ).tabs();');
        resultHtml = resultHtml.concat('        $(\'a[href="#leftpanel',objectIDMap[recordID]['kind'],'"]\').removeClass(\'ui-state-default\').addClass(\'ui-state-highlight\').trigger("click") ;');
        resultHtml = resultHtml.concat('});');
        resultHtml = resultHtml.concat('</script>');

        resultHtml = resultHtml.concat('<div id="packageleftpanelmain" >');

        resultHtml = resultHtml.concat('<div id="leftpaneltabs" >');
        resultHtml = resultHtml.concat('    <ul>');
        resultHtml = resultHtml.concat('        <li><a href="#leftpanelrecord">Record</a></li>');
        resultHtml = resultHtml.concat('        <li><a href="#leftpanelsearch">Search</a></li>');
        resultHtml = resultHtml.concat('        <li><a href="#leftpanelother">Other</a></li>');
        resultHtml = resultHtml.concat('        <li><a href="#leftpanelenum">Enum</a></li>');
        resultHtml = resultHtml.concat('    </ul>');

        for(var kind in {"record":"record","search":"search","other":"other","enum":"enum"})
        {
            resultHtml = resultHtml.concat('<div id="leftpanel',kind,'" class="ui-corner-all">');
            resultHtml = resultHtml.concat('<span id="',kind,'list" class="objectlistbuttons">');
            for(var recID in schemaPackageMap[ objectIDMap[recordID]['schemaPackage']][objectIDMap[recordID]['schemaXSDFile']][kind])
            {
                var refID=schemaPackageMap[ objectIDMap[recordID]['schemaPackage']][objectIDMap[recordID]['schemaXSDFile']][kind][recID];
                if ((kind=='record')&& (objectIDMap[refID][nametag]!=undefined))
                {
                    var buttonName=objectIDMap[refID][nametag];
                }
                else
                {
                    var buttonName= objectIDMap[refID][nametag2];
                }
                resultHtml = resultHtml.concat('<button id="',
                                               refID.replace(/:/g,"_").replace(/\./g,'_')
                        ,'" name="',kind,'switch"    onclick="window.location.href=\'',relativepathToRoot,'/',browserType,'/',kind,'/',
                                               refID.split('__')[1]
                        ,'.html?mode=package\'">',
                                               buttonName
                        ,'</button>');
                if(recordID==refID)
                {
                    resultHtml = resultHtml.concat('<script>');
                    resultHtml = resultHtml.concat('$(function() {');
                    resultHtml = resultHtml.concat('$(\'#',refID.replace(/:/g,"_").replace(/\./g,'_'),'\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\');');
                    resultHtml = resultHtml.concat('});');
                    resultHtml = resultHtml.concat('</script>');
                }
            }

            resultHtml = resultHtml.concat('</span>');
            resultHtml = resultHtml.concat('</div>');
        }

        resultHtml = resultHtml.concat('</div>');
        resultHtml = resultHtml.concat('</div>');
    }
    else if (mode=='domain')
    {
        var letter = objectIDMap[recordID][nametag].toUpperCase().charAt(0);

        resultHtml = resultHtml.concat('<script>');
        resultHtml = resultHtml.concat('$(function() {');
        resultHtml = resultHtml.concat('        $(".objectlistbuttons").buttonsetv();');
        resultHtml = resultHtml.concat('});');
        resultHtml = resultHtml.concat('</script>');

        resultHtml = resultHtml.concat('<div id="leftpanelmain" >');
        resultHtml = resultHtml.concat('<div id="leftpanelrecord" class="ui-corner-all" >');
        resultHtml = resultHtml.concat('<span id="recordlist" class="objectlistbuttons">');
        for (var recID in odbcDomainMap[actualDomain])
        {
            if(odbcDomainMap[actualDomain].hasOwnProperty(recID))
            {
                var recordName=objectIDMap[odbcDomainMap[actualDomain][recID]][nametag];
                if (recordName==undefined)
                {
                    recordName=objectIDMap[odbcDomainMap[actualDomain][recID]][nametag2];
                }
                recordName=recordName.charAt(0).toUpperCase()+recordName.substring(1);
                resultHtml = resultHtml.concat('<button id="',odbcDomainMap[actualDomain][recID],'" name="recordswitch"    onclick="window.location.href=\'',relativepathToRoot,'/',browserType,'/record/',
                                               odbcDomainMap[actualDomain][recID].split('__')[1],'.html?mode=domain&domain=',actualDomain.toLowerCase(),'\'">',recordName,'</button>');
                if(recordID==odbcDomainMap[actualDomain][recID])
                {
                    resultHtml = resultHtml.concat('<script>');
                    resultHtml = resultHtml.concat('$(function() {');
                    resultHtml = resultHtml.concat('$(\'#',odbcDomainMap[actualDomain][recID],'\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\');');
                    resultHtml = resultHtml.concat('});');
                    resultHtml = resultHtml.concat('</script>');
                }
            }
        }
        resultHtml = resultHtml.concat('</span>');
        resultHtml = resultHtml.concat('</div>');
        resultHtml = resultHtml.concat('</div>');
    }
    else if(mode=='new')
    {

        resultHtml = resultHtml.concat('<script>');
        resultHtml = resultHtml.concat('$(function() {');
        resultHtml = resultHtml.concat('        $(".objectlistbuttons").buttonsetv();');
        resultHtml = resultHtml.concat('});');
        resultHtml = resultHtml.concat('</script>');

        resultHtml = resultHtml.concat('<div id="leftpanelmain" >');
        resultHtml = resultHtml.concat('<div id="leftpanelrecord" class="ui-corner-all" >');
        resultHtml = resultHtml.concat('<span id="recordlist" class="objectlistbuttons">');
        for (var recID in scriptNewList)
        {
            if(scriptNewList.hasOwnProperty(recID))
            {
                var recordName=objectIDMap[scriptNewList[recID]][nametag];
                if (recordName==undefined)
                {
                    recordName=objectIDMap[scriptNewList[recID]][nametag2];
                }
                recordName=recordName.charAt(0).toUpperCase()+recordName.substring(1);
                resultHtml = resultHtml.concat('<button id="',scriptNewList[recID],'" name="recordswitch"    onclick="window.location.href=\'',relativepathToRoot,'/',browserType,'/record/',
                    scriptNewList[recID].split('__')[1],'.html?mode=new\'">',recordName,'</button>');
                if(recordID==scriptNewList[recID])
                {
                    resultHtml = resultHtml.concat('<script>');
                    resultHtml = resultHtml.concat('$(function() {');
                    resultHtml = resultHtml.concat('$(\'#',scriptNewList[recID],'\').button("option", "disabled", true).addClass(\'ui-state-highlight\').removeClass(\'ui-state-disabled\');');
                    resultHtml = resultHtml.concat('});');
                    resultHtml = resultHtml.concat('</script>');
                }
            }
        }
        resultHtml = resultHtml.concat('</span>');
        resultHtml = resultHtml.concat('</div>');
        resultHtml = resultHtml.concat('</div>');
    }
    return resultHtml;
}


function fileExists(url) {
    if(url){
        var req = new XMLHttpRequest();
        req.open('HEAD', url, false);
        req.send();
        return req.status==200;
    } else {
        return false;
    }
}

function isEmpty(map) {
    for(var key in map) {
        if (map.hasOwnProperty(key)) {
            return false;
        }
    }
    return true;
}

function updateLinks(browserType)
{
    var isScript=!isEmpty(scriptAlphaMap);
    var isSchema=!isEmpty(schemaAlphaMap);
    var isOdbc=!isEmpty(odbcAlphaMap);
    var isAnalytics=!isEmpty(analyticsAlphaMap);
    if (browserType=='schema')
    {
        if ( !isScript ) $('#scriptli').hide();
        if ( !isOdbc ) $('#odbcli').hide();
        if ( !isAnalytics ) $('#analyticscli').hide();
    }
    else if (browserType=='script')
    {
        var urlMode=getURLParameter('single');
        var isSingle= (urlMode=='t' || urlMode=='true' || urlMode=='True' || urlMode=='T' || urlMode=='TRUE');
        if (isSingle)
        {

            //$('#mainheader').hide();
            //$('#leftpanel').hide();

            if (isSingle)
            {
                $("a").attr('href', function(i, h) {
                    return h + (h.indexOf('?') != -1 ? "&single=t" : "?single=t");
                });
                $("button[onclick]").attr('onclick', function(i, h) {
                    return h.substring(0, h.length-1) + (h.indexOf('?') != -1 ? "&single=t'" : "?single=t'");
                });
            }
        }
        if ( !isSchema ) $('#schemali').hide();
        if ( !isOdbc ) $('#odbcli').hide();
        if ( !isAnalytics ) $('#analyticscli').hide();
    }
    else if (browserType=='odbc')
    {
        if ( !isScript ) $('#scriptli').hide();
        if ( !isSchema ) $('#schemali').hide();
        if ( !isAnalytics ) $('#analyticscli').hide();

    }
    else if (browserType=='analytics')
    {
        if ( !isScript ) $('#scriptli').hide();
        if ( !isSchema ) $('#schemali').hide();
        if ( !isOdbc ) $('#odbcli').hide();
    }
}

function wrapBodyDiv(browserType,divName,relativepathToRoot)
{
    var mode='letter';
    if (browserType=='schema')
    {
        var urlMode=getURLParameter('mode');
        if (urlMode=='package')
        {
            mode=urlMode;
        }
    }
    else
    {
        var urlField= getURLParameter('field');
        if (urlField)
        {
            //if(urlField.endsWith('_'))
            $('#field_'+urlField).addClass("selectedField")
//            if(urlField.indexOf('_', urlField.length - 1) !== -1)
//            {
//                $('#field_'+urlField).addClass("selectedField");
//            }
//            else
//            {
//                $('#field_'+urlField+' > td').addClass("selectedField");
//            }
        }
    }
    updateLinks(browserType);
    if(mode=='letter')
    {
        $('#'+divName).wrap('<div id="panelmain"></div>')
    }
    else
    {
        $('#'+divName).wrap('<div id="packagepanelmain"></div>')
    }
}

function cap_first(string)
{
    if (!(typeof string == 'string' || string instanceof String))
        return null;
    else if (string.length < 2)
        return string.charAt(0).toUpperCase();
    else
        return string.charAt(0).toUpperCase() + string.substring(1).toLowerCase();
}
