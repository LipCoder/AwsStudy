// require는 모듈을 불러오는 데 쓰인다.
var jmespath = require('jmespath');
var AWS = require('aws-sdk');

// EC2 엔드포인트를 구성
var ec2 = new AWS.EC2({
	"region": "us-east-1"
});

module.exports = function(cb) {	// module.exports 를 사용하면 listAMIs 모듈 사용자가 이 함수를 사용할 수 있다 
	ec2.describeImages({		// 액션
		"Filters": [{
			"Name": "description",
			"Values": ["Amazon Linux AMI 2015.03.? x86_64 HVM GP2"]
		}]
	}, function(err, data) {
		if (err) {
			cb(err);
		} else {
			var amiIds = jmespath.search(data, 'Images[*].ImageId');			// 필터링된 모든 이미지 ID를 찾는다
			var descriptions = jmespath.search(data, 'Images[*].Description');	// 필터링된 모든 이미지의 상세정보를 찾는다
			cb(null, {"amiIds": amiIds, "descriptions": descriptions});
		}
	});
};
