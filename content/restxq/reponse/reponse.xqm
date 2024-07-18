xquery version "3.0";
module namespace reponse="http://www.insee.fr/collectes/reponse";
import module namespace common= "http://www.insee.fr/collectes/commonstromae/common" at "../common/commonStromae.xqm";

declare
%rest:GET
%rest:path("/collectes/reponse/{$enquete}/{$modele}/{$unite}")
function reponse:get-reponse ( $enquete as xs:string*, $modele as xs:string*,$unite as xs:string*) as node()* 
{
let $col := common:calcol($unite)
let $doc := concat('/db/orbeon/fr/',$enquete,'/',$modele,'/data/','init/',$col,'/',$unite,'.xml')
return 
if (doc-available($doc)) then (doc($doc))
else (common:rest-response(404,"Fichier reponse introuvable"))
};


