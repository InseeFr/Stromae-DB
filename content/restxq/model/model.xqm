xquery version "3.0";
module namespace model="http://www.insee.fr/collectes/model";
import module namespace common= "http://www.insee.fr/collectes/commonstromae/common" at "../common/commonStromae.xqm";

declare
%rest:GET
%rest:path("/model/{$enquete}/{$unite}")
function model:get-model ($enquete as xs:string*, $unite as xs:string*) as node()*
{
    
let $racine-enquete-full := concat('/db/orbeon/fr/',lower-case($enquete),'/')
let $col := common:calcol($unite)
let $cheminfic := concat('/data/init/',$col,'/',$unite,'.xml')
let $model := 
    for $collection-modele in xmldb:get-child-collections($racine-enquete-full)
    let $chemintotal := concat($racine-enquete-full,$collection-modele,$cheminfic) where doc-available($chemintotal) 
    return $collection-modele 

return 
<model>{$model}</model>

};