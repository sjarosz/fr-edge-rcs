# fr-edge-rcs

ForgeRock container for the Remote Connector Server.
This is designed to be run in Kubernetes environment and with partial configuration to speak to a ForgeRock Identity Cloud tenant.

Edit the conf/ConnectorServer.properties:


1) Make these match your tenant URL
    `connectorserver.url`
    `connectorserver.tokenEndpoint` 
    
2) Update the following for your OAuth2 Client
     `connectorserver.clientId`
     `connectorserver.clientSecret`
     
3) The unique connector server name 
    The name given here must match a configuration on the IDM side, for the
    connection to be made.
    
    `connectorserver.connectorServerName`
