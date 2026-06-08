const functions = require("firebase-functions");
const cloudinary = require("cloudinary").v2;

// We will use process.env to read from a .env file locally. 
// Firebase will automatically securely deploy this to the Cloud environment.
const CLOUD_NAME = process.env.CLOUDINARY_CLOUD_NAME || "dijbs5ulp";
const API_KEY = process.env.CLOUDINARY_API_KEY;
const API_SECRET = process.env.CLOUDINARY_API_SECRET;

cloudinary.config({
    cloud_name: CLOUD_NAME,
    api_key: API_KEY,
    api_secret: API_SECRET,
    secure: true
});

exports.getCloudinarySignature = functions.https.onCall((data, context) => {
    // 1. Ensure user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'You must be logged in to upload images.'
        );
    }

    // 2. Ensure API Key and Secret are configured
    if (!API_KEY || !API_SECRET) {
        console.error("Cloudinary credentials are not set in the environment.");
        throw new functions.https.HttpsError(
            'internal',
            'Server configuration error.'
        );
    }

    // 3. Generate a signature
    const timestamp = Math.round((new Date).getTime() / 1000);
    
    // We only sign the timestamp for basic uploads, but you can add 'folder' or other parameters here
    const paramsToSign = {
        timestamp: timestamp
    };

    const signature = cloudinary.utils.api_sign_request(paramsToSign, API_SECRET);

    return {
        signature: signature,
        timestamp: timestamp,
        cloud_name: CLOUD_NAME,
        api_key: API_KEY
    };
});
