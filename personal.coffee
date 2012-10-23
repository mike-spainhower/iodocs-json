fs = require 'fs'

###
# Procedurally generate IO Docs for Personal API
# author: Mike Spainhower
# usage: nodejs personal.js
###

#The oauth object
iodocs_oauth =
    oauth:
        version: "2.0"
        base_uri: "https://api-sandbox.personal.com"
        authorize_uri: "/oauth/authorize"
        access_token_uri: "/oauth/access_token"
        auth_flows: ["auth_code"]
        options :
            authorize:
                scope: [] #what do we need here?

#Root object that will the JSONified
iodocs_obj =
    name: "Personal API"
    version: "1.0"
    title: "Personal API"
    description: "This is the IO Docs for the Personal API"
    protocol: "rest"
    basePath: "https://api-sandbox.personal.com"
    auth: iodocs_oauth
    resources: {}

#standard API path prefix
api_path_pre = "/api/v1/"

#http verbs
get = "GET"
put = "PUT"
post= "POST"
del = "DELETE"

#method parameter locations
loc_pr = "pathReplace"
loc_q = "query"
loc_h = "header"

#Parameters we may wish to reuse multiple times
gem_instance_id =
    type: "string"
    required: true
    description: "Instance ID of a specific gem in the form <user_id>#<template_id>#<gem_id>"
    location: loc_pr

auth_hdr =
    type: "string"
    required: true
    description: "Bearer <access_token>"
    location: loc_h

sec_pwd =
    type: "string"
    required: true
    description: "<password>"
    location: loc_h

#Create a list of resources and add to iodocs_obj later
resources = []

###Define our resources (add them to array)###

#Gems
resources.push
    name: "Gems"
    methods:
        "Get Gem List":
            path: "#{api_path_pre}gems/:filter"
            httpMethod: get
            description: "Retrieve a list of gem IDs and corresponding names"
            parameters:
                ":filter":
                    type: "string"
                    required: false
                    description: "Filter only certain gem instances"
                    enum: ["my", "others"]
                    enumDescriptions: [
                        "Filter only the user's gems", #my
                        "Filter only gems that others have shared to the user" #others
                    ]
                    location: loc_pr
                Authorization: auth_hdr
        "Read Existing Gem":
            path: "#{api_path_pre}gems/:gem_instance_id"
            httpMethod: get
            description: "Gets the gem data for specified gem instance id."
            parameters:
                ":gem_instance_id": gem_instance_id
                "Authorization": auth_hdr
                "Secure-Password": sec_pwd
        "Write to Existing Gem":
            path: "#{api_path_pre}gems/:gem_instance_id"
            httpMethod: put
            description: "Write to existing gem. Values specified in the JSON are saved in the database. Values NOT specified in the JSON that already exist in database will be deleted."
            parameters:
                ":gem_instance_id": gem_instance_id
                "Authorization": auth_hdr
                "Secure-Password": sec_pwd
        "Create New Gem":
            path: "#{api_path_pre}gems"
            httpMethod: post
            description: "Creates a new gem based on request's json body and returns the new gem with instance ID"
            parameters:
                "Authorization": auth_hdr
                "Secure-Password": sec_pwd
        "Delete Existing Gem":
            path: "#{api_path_pre}gems/:gem_instance_id"
            httpMethod: post
            description: "Deletes an existing gem and returns the gem as json"
            parameters:
                ":gem_instance_id": gem_instance_id
                "Authorization": auth_hdr
            
#Add resources to root object
for res in resources
    iodocs_obj.resources[res.name] = {methods: {}}
    iodocs_obj.resources[res.name].methods = res.methods

#Write output
filename = "personal.json" #maybe take this from cmd line args
fs.writeFile filename, JSON.stringify(iodocs_obj, undefined, 2), (err) ->
    if err then console.log err else console.log "Wrote json to #{filename}"
