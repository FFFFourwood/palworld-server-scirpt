# palworld-server-scirpt
When the memory is insufficient, Automatically restart the Palworld game service and send notifications to iPhone and WeCom robots.

# The places you need to modify.
{wecomkey} ： Your own WeCom key.
{barkkey}：  The Key of a Mobile Push Notification App: Bark

# Available memory limit (unit: MB), here is 300MB.
MEM_LIMIT=300

# Restart PalServer.sh every four hours.
if ((SECONDS >= 14400));

