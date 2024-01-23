# palworld-server-scirpt
When the memory is insufficient, restart the Palworld game service and send notifications to iPhone and WeChat Work robots.

# The places you need to modify.
{wecomkey} ： Your own WeCom key.
{barkkey}：  The Key of a Mobile Push Notification App: Bark

# Available memory limit (unit: MB), here is 0.5GB.
MEM_LIMIT=500

# Restart PalServer.sh every four hours.
if ((SECONDS >= 14400));

