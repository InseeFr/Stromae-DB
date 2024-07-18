xquery version "3.0";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace model="http://www.insee.fr/collectes/model" at "../restxq/model/model.xqm";
import module namespace common= "http://www.insee.fr/collectes/commonstromae/common" at "../restxq/common/commonStromae.xqm";


declare option exist:serialize "method=xml media-type=text/xml";

let $data := request:get-data()
let $path := request:get-parameter('path', ())
let $httpmethod := request:get-method()
let $xqm := tokenize($path, '/')[2]


(: <WebService verbe="GET"    path="/model/{$enquete}/{$unite}" file="/db/restxq/model/model.xqm"/> :)

let $rez := if (($xqm eq 'model') and ($httpmethod eq 'GET') and (count(tokenize($path, '/')) eq 4)) then

    let $enquete := tokenize($path, '/')[3]
    let $ue := tokenize($path, '/')[4]
    
    let $instance := model:get-model($enquete,$ue)

    return common:xql-response($instance)
    
else 
    (response:set-status-code(400),<BadRequest/>)
    
return $rez    
