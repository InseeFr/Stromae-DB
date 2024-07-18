xquery version "3.0";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace pogues="http://xml.insee.fr/schema/applis/pogues" at "../restxq/visualize/visualize.xqm";
import module namespace common= "http://www.insee.fr/collectes/commonstromae/common" at "../restxq/common/commonStromae.xqm";


declare option exist:serialize "method=text media-type=text/html";

let $data := request:get-data()
let $path := request:get-parameter('path', ())
let $httpmethod := request:get-method()
 
let $rez := if (($httpmethod eq 'POST') and (count(tokenize($path, '/')) eq 4)) then 

(: <WebService verbe="POST"    path="/visualize/{$dataCollection}/{$model}" file="/db/restxq/reponse/visualize.xqm"/> :)
        
    let $dataCollection := tokenize($path, '/')[3]
    let $model := tokenize($path, '/')[4]
    let $instance := pogues:post-publish($data,$dataCollection,$model)
    return $instance

else 
    (response:set-status-code(400),<BadRequest/>)
    
return $rez
