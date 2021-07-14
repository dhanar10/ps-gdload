# Based on:
# https://gist.github.com/RGPaul/f1a306097d46a69a09c25ca34b79a804
# https://hodgkins.io/download-file-with-powershell-without-renaming

function gdload()
{
  param([string]$FILE_URL)
  $FILE_ID = $FILE_URL.split('/')[-2]
  invoke-webrequest -uri "https://drive.google.com/uc?export=download&id=${FILE_ID}" -OutFile "_tmp.txt" -SessionVariable googleDriveSession
  $CONFIRM_SEARCH = Select-String -Path "_tmp.txt" -Pattern "confirm="
  if (!($CONFIRM_SEARCH -match "confirm=(?<code>.*)&amp;id=")) { throw "Confirm code not found!" }
  $CONFIRM_CODE = $matches['code']
  Remove-Item "_tmp.txt"
  $RESPONSE = invoke-webrequest -usebasicparsing -uri "https://drive.google.com/uc?export=download&confirm=${CONFIRM_CODE}&id=${FILE_ID}" -WebSession $googleDriveSession
  $CONTENT = [System.Net.Mime.ContentDisposition]::new($RESPONSE.Headers["Content-Disposition"])
  $OUT_FILE = [System.IO.FileStream]::new($CONTENT.FileName, [System.IO.FileMode]::Create)
  $OUT_FILE.Write($RESPONSE.Content, 0, $RESPONSE.RawContentLength)
  $OUT_FILE.Close()
}
