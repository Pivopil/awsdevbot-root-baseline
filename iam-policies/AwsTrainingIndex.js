const AWS = require('aws-sdk');

const iam = new AWS.IAM({apiVersion: '2010-05-08'});

const users = [];

// https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/IAM.html#createUser-property
// PermissionsBoundary: 'STRING_VALUE',
const iamCreateUser = (UserName) => iam.createUser({Path: '/gl/', UserName, Tags: [{ Key: 'org', Value: 'gl' }]}).promise();
const iamGetUser = (UserName) => iam.getUser({UserName}).promise();

// https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/IAM.html#addUserToGroup-property
const iamAddUserToGroup = (UserName, GroupName) =>  iam.addUserToGroup({ UserName, GroupName }).promise();

// https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/IAM.html#createLoginProfile-property
const iamCreateLoginProfile = (UserName) => iam.createLoginProfile({
    Password: process.env.DEFAULT_PASSWORD,
    UserName,
    PasswordResetRequired: true
}).promise();

const createIamUsersFlow = async (UserName) => {
    let isNewUser = false;
    let user = null;
    try {
        user = await iamGetUser(UserName);
    } catch (e) {
        if (e.code === 'NoSuchEntity') {
            isNewUser = true;
        } else {
            throw new Error(e);
        }
    }

    if (isNewUser) {
        user = await iamCreateUser(UserName)
    }

    await iamAddUserToGroup(UserName, 'SelfChangePasswordGroup');
    await iamAddUserToGroup(UserName, 'log-limit');
    await iamAddUserToGroup(UserName, 'Developers');
    try {
        const iamCreateLoginProfileResponse = await iamCreateLoginProfile(UserName);
    } catch (e) {
        if (e.code !== 'EntityAlreadyExists') throw Error(e);
    }
    return {status: 'done'}
};

// Step One - Initial Role
const createGLUsersIfNotExistsAndAddThemToGroups = async () => {
    for (let index = 0; index < users.length; index++) {
        await createIamUsersFlow(users[index]);
        console.log(`${users[index]} is done`)
    }
    return {status: 'All done'};
};

createGLUsersIfNotExistsAndAddThemToGroups().then(d => {
        return
    }).catch(e => {
    return
});




