## PagSeguro Handler Endpoint

**Description:**

This project was created at the year of 2017. It was a HTTP endpoint created over
RoR (Ruby on Rails) that was running over a NGINX server at the Digital Ocean. 
This was used with a hybrid mobile app, in order to handle notifications 
originated by a payment handler, which was the PagSeguro.

When HTTP actions reaches this endpoint, the DynamoDB (AWS) were update properly. 
The overall architecture was something like this:

![Architecture](architecture.png?raw=true "Architecture")

**Major components:**

- aws-sdk;
- pagseguro-sdk (ruby);

**Notes:** this project is legacy and it’s not running anymore;