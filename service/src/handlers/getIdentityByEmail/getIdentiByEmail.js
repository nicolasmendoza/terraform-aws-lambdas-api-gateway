/* getIdentityByEmail -> /users/emails/{email} */

'use strict';
/* verifyToken - > /authorize */

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
            message: "Hello World!",
        }),
    };
    return response;
};



module.exports = {handler};
