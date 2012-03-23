

var codeMirrorEditors = {};

function initCodeMirror(elementId) {
  codeMirrorEditors[elementId] = CodeMirror.fromTextArea(document.getElementById(elementId), 
                                                         { lineNumbers: true });
}

function refreshCodeMirrors() {
  for (elementId in codeMirrorEditors) {
    if (codeMirrorEditors.hasOwnProperty(elementId)) {
      codeMirrorEditors[elementId].refresh();
    }
  }
}

function getVariables(variablesString) {
  variablesString = variablesString.replace(/[ \t\r\n]+/g,"");
  return variablesString.split(",");
}

function runCode(seed, code, variables, existingVariables) {
  var wrapper = {
    runCode: function() {
      Math.seedrandom(seed);
    
      for (existingVariable in existingVariables) {
        eval(existingVariable + ' = ' + existingVariables[existingVariable]);  
      }
    
      eval(code);

      results = {};

      for (ii = 0; ii < variables.length; ii++) {
        results[variables[ii]] = eval(variables[ii] + ".toString();");
      }
      for (ii = 0; ii < existingVariables.length; ii++) {
        results[existingVariables[ii]] = eval(existingVariables[ii] + ".toString();")
      }
    
      return results;                  
    }
  }

  results = wrapper.runCode();
  //console.log(results);
  return results;
}

function test_logic(counter) {

  var existingVariables = {};
  var seed = $('#seed_' + counter).val();
  for (jj = 1; jj <= counter; jj++) {
    code = codeMirrorEditors['code_editor_'+jj].getValue();
    variables = getVariables($('#variables_'+jj).val());
    existingVariables = runCode(seed, code, variables, existingVariables);
  }

  // code = "Math.seedrandom(" + $('#seed_' + counter).val() + ");" + codeMirrorEditors['code_editor_'+counter].getValue();
  // results = runCode(code, getVariables($('#variables_'+counter).val()));
  results_elem = $('#results_'+counter);
  results_elem.html('');
  results_elem.show();
  for (variable in existingVariables) {
    results_elem.append(variable + ' = ' + existingVariables[variable] + "<br/>");  
  }
}

