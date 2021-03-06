'use strict';
/* verifyToken - > /authorize */

const utils = require('../../utils');

function handler(event, context, callback) {
    /**
     * Checks if a JWT token provided to the service is valid
     */
    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: JSON.stringify({
            message: "Hello from VerifyToken!",
        }),
    };
    callback(null, response);
}

module.exports = {handler};
