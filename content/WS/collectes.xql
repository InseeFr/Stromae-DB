xquery version "3.0";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace reponse="http://www.insee.fr/collectes/reponse" at "../restxq/reponse/reponse.xqm";
import module namespace form="http://www.insee.fr/collectes/form" at "../restxq/form/form.xqm";
import module namespace common= "http://www.insee.fr/collectes/commonstromae/common" at "../restxq/common/commonStromae.xqm";


declare option exist:serialize "method=xml media-type=text/xml";

let $data := request:get-data()
let $path := request:get-parameter('path', ())
let $httpmethod := request:get-method()
let $xqm := tokenize($path, '/')[3]
 
let $rez := if (($xqm eq 'reponse') and ($httpmethod eq 'GET') and (count(tokenize($path, '/')) eq 6)) then 

(: <WebService verbe="GET"    path="/collectes/reponse/{$enquete}/{$modele}/{$unite}" file="/db/restxq/reponse/reponse.xqm"/> :)
        
    let $enquete := tokenize($path, '/')[4]
    let $model := tokenize($path, '/')[5]
    let $ue := tokenize($path, '/')[6]
    let $instance := reponse:get-reponse($enquete,$model,$ue)
    return common:xql-response($instance)
 
else if (($xqm eq 'form') and ($httpmethod eq 'GET') and (count(tokenize($path, '/')) eq 6)) then
    
(: <WebService verbe="GET"    path="/collectes/form/{$enquete}/{$modele}/{$unite}" file="/db/restxq/form/form.xqm"/> :)   
    
    let $enquete := tokenize($path, '/')[4]
    let $model := tokenize($path, '/')[5]
    let $ue := tokenize($path, '/')[6]
    let $instance := form:get-instance($enquete,$model,$ue)

    return common:xql-response($instance)

else 
    (response:set-status-code(400),<BadRequest/>)
    
return $rez    
