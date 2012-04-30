// Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
// License version 3 or later.  See the COPYRIGHT file for details.

Quadbase.CodeMirrorUtils = function() {

  var fixedLogic = [];
  var codeMirrorEditors = {};

  var getVariables = function(variablesString) {
    variablesString = variablesString.replace(/[ \t\r\n]+/g,"");
    return variablesString.split(",");
  }
  
  var runCode = function(seed, code, variables, existingVariables, libraryScripts) {
    var wrapper = {
      runCode: function() {        
        for (ii = 0; ii < libraryScripts.length; ii++) {
          eval(libraryScripts[ii]);
        }
        
        Math.seedrandom(seed);

        // Clear out the existing variables from the global space
        for (ii = 0; ii < variables.length; ii++) {
          eval(variables[ii] + ' = undefined');
        }
    
        // Make sure existing variables can be accessed by the new code
        for (existingVariable in existingVariables) {
          if (existingVariables.hasOwnProperty(existingVariable)) {
            eval(existingVariable + ' = ' + existingVariables[existingVariable]);              
          }
        }
    
        // Evaluate the code
        try {
          eval(code); 
        } 
        catch (e) {
          alert("An error occurred when trying to run this code: '" + e.message + "'");
        }
    
        // Copy the exported variables to the results object; then put the existing
        // variables in the results object (they should never change so write them 
        // second so that they undo any changes from this code).
        
        results = {};

        for (ii = 0; ii < variables.length; ii++) {
          results[variables[ii]] = eval(variables[ii]); // + ".toString();");
        }
        for (existingVariable in existingVariables) {
          if (existingVariables.hasOwnProperty(existingVariable)) {
            results[existingVariable] = existingVariables[existingVariable];
          }
        }
    
        return results;                  
      }
    }

    results = wrapper.runCode();
    //console.log(results);
    return results;
  }
  
  var JSLINT_OPTIONS = {devel: false, 
                        bitwise: true, 
                        undef: true, 
                        continue: true, 
                        unparam: true, 
                        debug: true, 
                        sloppy: true, 
                        eqeq: true, 
                        sub: true, 
                        es5: true, 
                        vars: true, 
                        evil: true, 
                        white: true, 
                        forin: true, 
                        passfail: false, 
                        newcap: true, 
                        nomen: true, 
                        plusplus: true, 
                        regexp: true, 
                        maxerr: 50, 
                        indent: 4};
  
  var checkCode = function(code, resultsElement, checkingPriorLogic) {
    if (JSLINT(code, JSLINT_OPTIONS)) {
      return true;
    }
    else {
      for (ee = 0; ee < JSLINT.errors.length; ee++) {
        error = JSLINT.errors[ee];
        
        if (null == error || (/Stopping/).test(error.reason)) break;
          
        message = "";
        
        if (ee > 0) 
          message += "<div class='logic_error_separator'></div>";
          
        if (checkingPriorLogic) 
          message += "(Prior Logic) ";

        message += "Line " + error.line;
        message += ", character " + error.character;
        message += ": " + error.reason;
        message += " (" + error.evidence;
        message += ")<br/>";
     
        resultsElement.append(message);
      }
      
      resultsElement.show();
      return false;      
    }
  }

  return {
    loadFixedLogic: function(code, variables) {
      fixedLogic.push({code: code, variables: variables});
    },
    
    initCodeMirror: function(elementId, options) {
      options = typeof options !== 'undefined' ? options : { lineNumbers: true };
      codeMirrorEditors[elementId] = CodeMirror.fromTextArea(document.getElementById(elementId), 
                                                             options);
    },

    saveCodeMirrors: function() {
      for (elementId in codeMirrorEditors) {
        codeMirrorEditors[elementId].save();
      }
    },
    
    refreshCodeMirrors: function() {
      for (elementId in codeMirrorEditors) {
        if (codeMirrorEditors.hasOwnProperty(elementId)) {
          codeMirrorEditors[elementId].refresh();
        }
      }
    },
    
    testLogic: function(counter) {
      var existingVariables = {};
      var seed = $('#seed_' + counter).val();

      results_elem = $('#results_'+counter);
      results_elem.html('');
      
      // Run through the fixed code (that code which is part of 
      // this question but not in a codeMirror on this page)
      for (kk = 0; kk < fixedLogic.length; kk++) {
        existingVariables = runCode(seed++, fixedLogic[kk].code, fixedLogic[kk].variables, existingVariables);
      }

      for (jj = 1; jj <= counter; jj++) {
        code = codeMirrorEditors['code_editor_'+jj].getValue();
        if (!code) continue;

        variables = getVariables($('#variables_'+jj).val());
        
        // See which scripts are needed, and pull them from their dom elements.
        var libraryScripts = new Array();
        $.each($(".library_checkbox_" + jj + ":checked"), function() {
          version_id = $(this).val();
//          alert(version_id);
          script = $('#library_' + version_id).html();
          libraryScripts.push(script);
  //        alert(script);
        });

        if (!checkCode(code, results_elem, jj != counter)) return;
      //  alert('past check code');
        existingVariables = runCode(seed++, code, variables, existingVariables, libraryScripts);
      }

      for (variable in existingVariables) {
        if (existingVariables.hasOwnProperty(variable)) {
          results_elem.append(variable + ' = ' + existingVariables[variable] + "<br/>");  
        }
      }
      
      results_elem.show();
    }
  }

}();

