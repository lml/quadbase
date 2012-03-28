Quadbase.CodeMirrorUtils = function() {

  var fixedLogic = [];
  var codeMirrorEditors = {};

  var getVariables = function(variablesString) {
    variablesString = variablesString.replace(/[ \t\r\n]+/g,"");
    return variablesString.split(",");
  }
  
  var runCode = function(seed, code, variables, existingVariables) {
    var wrapper = {
      runCode: function() {
        Math.seedrandom(seed);
    
        for (existingVariable in existingVariables) {
          if (existingVariables.hasOwnProperty(existingVariable)) {
            eval(existingVariable + ' = ' + existingVariables[existingVariable]);              
          }
        }
    
    
        try {
          eval(code); 
        } 
        catch (e) {
          alert("An error occurred when trying to run this code: '" + e.message "'");
        }
    
        results = {};

        for (ii = 0; ii < variables.length; ii++) {
          results[variables[ii]] = eval(variables[ii] + ".toString();");
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
  
  var jslintOptions = {devel: false, bitwise: true, undef: true, continue: true, unparam: true, debug: true, sloppy: true, eqeq: true, sub: true, es5: true, vars: true, evil: true, white: true, forin: true, passfail: false, newcap: true, nomen: true, plusplus: true, regexp: true, maxerr: 50, indent: 4};
  
  var checkCode = function(code, resultsElement, checkingPriorLogic) {
    if (JSLINT(code, jslintOptions)) {
      return true;
    }
    else {
      for (ee = 0; ee < JSLINT.errors.length; ee++) {
        error = JSLINT.errors[ee];
        if (null != error && !(/Stopping/).test(error.reason)) {
          if (ee > 0) {
            resultsElement.append("<div class='logic_error_separator'></div>");
          }
          if (checkingPriorLogic) {
            resultsElement.append("(Prior Logic) ");
          }
          resultsElement.append("Line " + error.line + ", character " + error.character + ": " + error.reason + "(" + error.evidence + ")" + "<br/>");          
        }
      }
      resultsElement.show();
      return false;      
    }
  }

  return {
    loadFixedLogic: function(code, variables) {
      fixedLogic.push({code: code, variables: variables});
    },
    
    initCodeMirror: function(elementId) {
      codeMirrorEditors[elementId] = CodeMirror.fromTextArea(document.getElementById(elementId), 
                                                             { lineNumbers: true });
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
      
      var jslintPassed;
      
      // Run through the fixed code (that code which is part of 
      // this question but not in a codeMirror on this page)
      for (kk = 0; kk < fixedLogic.length; kk++) {
        existingVariables = runCode(seed++, fixedLogic[kk].code, fixedLogic[kk].variables, existingVariables);
      }

      for (jj = 1; jj <= counter; jj++) {
        code = codeMirrorEditors['code_editor_'+jj].getValue();
        if (!code) continue;

        variables = getVariables($('#variables_'+jj).val());

        if (!checkCode(code, results_elem, jj != counter)) return;

        existingVariables = runCode(seed++, code, variables, existingVariables);
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

