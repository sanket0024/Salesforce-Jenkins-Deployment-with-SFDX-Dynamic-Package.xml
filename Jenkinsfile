#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"

    def HUB_ORG='DEV HUB ORG USERNAME'
    def SFDC_HOST = 'https://test.salesforce.com'
    def JWT_KEY_CRED_ID = 'SERVER.KEY FILE ID AS SAVED ON JENKINS'
    def CONNECTED_APP_CONSUMER_KEY='CONSUMER KEY OF THE CONNECTED APP'

    println 'KEY IS'
    println JWT_KEY_CRED_ID
    println HUB_ORG
    println SFDC_HOST
    println CONNECTED_APP_CONSUMER_KEY

    def toolbelt = tool 'toolbelt'

	stage('Create Package.xml file') {
		checkout scm
		rc = sh returnStatus: true, script: "sh ./dynamic-package.sh"
		if(rc != 0) {
			error: "package.xml not created"
		}
	}

    stage('checkout source') {
		List<String> diffNames = sh(returnStdout: true, script: "git diff --name-only HEAD~1 HEAD --diff-filter=ACMRTUXB").split()
		String diffFiles = ""
		diffNames.each {
			diffFiles = diffFiles + " " + it
		}
		diffFiles = diffFiles + " force-app/main/default/package.xml"
		println '*Files Changed*'
		println diffFiles
		rc = sh returnStatus: true, script: "git archive --output=deploy.zip HEAD ${diffFiles}"
		if(rc != 0) {
			error: "nothing fetched from Git"
		}
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Authorize Org`') {
            rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
            if (rc != 0) {
				error 'hub org authorization failed'
			}
        }

		stage('Deploy source to org') {
			rc = sh returnStatus: true, script: "${toolbelt} force:source:deploy --targetusername ${HUB_ORG} -x ./force-app/main/default/package.xml"
			if(rc != 0) {
				error 'Deployment failed'
			}
		}
    }
}