var codeMirrorEditors = [];

function initCodeMirror(elementId) {
  codeMirrorEditors.push(CodeMirror.fromTextArea(document.getElementById(elementId), 
                          { lineNumbers: true }) );
}

function refreshCodeMirrors() {
  for (ii = 0; ii < codeMirrorEditors.length; ii++) {
    codeMirrorEditors[ii].refresh();
  }      
}

function getVariables(variablesString) {
  variablesString = variablesString.replace(/[ \t\r\n]+/g,"");
  return variablesString.split(",");
}

function runCode(code, variables) {
  var wrapper = {
    runCode: function() {
      eval(code);

      results = {};

      for (ii = 0; ii < variables.length; ii++) {
        results[variables[ii]] = eval(variables[ii] + ".toString();");
      }
      return results;                  
    }
  }
  
  results = wrapper.runCode();
  console.log(results);
  return results;
}
