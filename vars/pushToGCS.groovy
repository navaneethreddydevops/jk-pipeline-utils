#!/usr/bin/env groovy

/**
* Upload static assets to AWS S3
* @param filePath
* @paramc bucketName
*/
Void call(String filePath, String bucketName) {
    try {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_s3_id',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]) {
            sh returnStdout: false, script: """aws s3 cp \"/tmp/${env.LOCAL_PATH}/${filePath}\" s3://\"${bucketName}\"/${filePath}"""
        }
    } catch (err) {
        error("[ERR!] Pipeline execution error: ${err.message}")
    }
}
