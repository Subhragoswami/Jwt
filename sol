curl --location --request POST 'https://dev.epay.sbi/notification/v1/notify/email' \
--header 'Content-Type: application/json' \
--header 'Cookie: 0e4369a7a9882292f0be96d96f09c504=0f9a1c19e11ef0b3197e690f4c119a3b; KR01dd9f70=01890e9c13cada180b81bdf05f62e7fab25fa3fa0958c63182887b329fab2982d8fcc488a5fcf5de07756842ce486158688a4c26bbfe27a3dbbbbb9b75ca260841d397c242' \
--data-raw '{
    "recipient" : "ebms_uat_receiver@ebmsgits.sbi.co.in",
    "subject" : "Hi",
    "from" : "ebms_uat_sender@ebmsgits.sbi.co.in",
    "cc" : "",
    "bcc" : "",
    "body" : "Hello",
    "emailType" : "CUSTOMER"
}'







https://10.176.245.230/aurora/#mail/1172652028/INBOX/msg5%3AINBOX%3A16478
