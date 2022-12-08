## CONFIGURING AMAZON OPENSEARCH ACCESS

Mapping Roles to Users

Role mapping is the most critical aspect of fine-grained access control. Fine-grained access control has some predefined roles to help you get started, but unless you map roles to users, every request to the cluster ends in a permissions error.

Backend roles offer another way of mapping roles to users. Rather than mapping the same role to dozens of different users, it can be mapped to a single backend role, and ensure that all users have that backend role. 

Backend roles can be IAM roles or arbitrary strings that can be specified when users are created in the internal user database.


Fluent Bit ARN will be added as a backend role to the all_access role using the Amazon OpenSearch API


```shell
./access.sh
```

*output:*

{
  "status" : "OK",
  "message" : "'all_access' updated."
}
