'use strict';

function buildClientResponse(handlerName) {
    return "Hello from"+ handlerName +"lambda function.";
};

module.exports = {
    buildClientResponse,
};