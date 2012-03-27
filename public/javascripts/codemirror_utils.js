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
    
        eval(code);

        results = {};

        for (ii = 0; ii < variables.length; ii++) {
          results[variables[ii]] = eval(variables[ii] + ".toString();");
        }
        for (existingVariable in existingVariables) {
          results[existingVariable] = existingVariables[existingVariable];
        }
    
        return results;                  
      }
    }

    results = wrapper.runCode();
    //console.log(results);
    return results;
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
      
      // Run through the fixed code (that code which is part of 
      // this question but not in a codeMirror on this page)
      for (kk = 0; kk < fixedLogic.length; kk++) {
        existingVariables = runCode(seed++, fixedLogic[kk].code, fixedLogic[kk].variables, existingVariables);
      }

      for (jj = 1; jj <= counter; jj++) {
        code = codeMirrorEditors['code_editor_'+jj].getValue();
        if (!code) continue;
        variables = getVariables($('#variables_'+jj).val());
        existingVariables = runCode(seed++, code, variables, existingVariables);
      }

      results_elem = $('#results_'+counter);
      results_elem.html('');
      results_elem.show();
      for (variable in existingVariables) {
        
        results_elem.append(variable + ' = ' + existingVariables[variable] + "<br/>");  
      }
    }
  }

}();

