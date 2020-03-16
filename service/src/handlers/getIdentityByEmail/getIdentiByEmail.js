'use strict';

/* getIdentityByEmail -> /users/emails/{email} */

const handler = async event => {
    /**
     * Checks if a JWT token provided to the service is valid
     */
    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: JSON.stringify({
            message: "Hello from getIdentityByEmail!",
        }),
    };
    return response;
};



module.exports = {handler};
