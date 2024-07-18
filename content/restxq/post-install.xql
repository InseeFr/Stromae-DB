xquery version "1.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

xmldb:create-collection("/db","restxq"),
xmldb:move("/db/apps/restxq/common","/db/restxq"),
xmldb:move("/db/apps/restxq/model","/db/restxq"),
xmldb:move("/db/apps/restxq/form","/db/restxq"),
xmldb:move("/db/apps/restxq/reponse","/db/restxq"),
xmldb:move("/db/apps/restxq/util","/db/restxq"),
xmldb:move("/db/apps/restxq/visualize","/db/restxq"),
xmldb:move("/db/apps/restxq","/db/restxq","properties.xml")