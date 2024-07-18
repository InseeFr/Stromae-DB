xquery version "3.0";
module namespace form="http://www.insee.fr/collectes/form";
import module namespace common= "http://www.insee.fr/collectes/commonstromae/common" at "../common/commonStromae.xqm";

declare
%rest:GET
%rest:path("/collectes/form/{$enquete}/{$modele}/{$unite}")
function form:get-instance($enquete as xs:string*, $modele as xs:string*,$unite as xs:string*) as item()* 
{
let $col := common:calcol($unite)
let $doc-user := concat( '/db/orbeon/fr/',$enquete,'/',$modele,'/data/',$col,'/',$unite,'.xml')
let $doc-prerempli := concat( '/db/orbeon/fr/',$enquete,'/',$modele,'/data/init/',$col,'/',$unite,'.xml')
return if (doc-available($doc-user)) 
            then (doc($doc-user)//form)
             else (if(doc-available($doc-prerempli))
                        then(doc($doc-prerempli)//form)
                        else(<vide/>)       
      )
};

