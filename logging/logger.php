<?php
header('Access-Control-Allow-Origin: *');
if (
	!isset($_GET['is_a']) ||
	!isset($_GET['event_value']) ||
	!isset($_GET['event_name']) ||
	!isset($_GET['event_category']) ||
	!isset($_GET['screen_name']) ||
	!isset($_GET['screen_token']) ||
	!isset($_GET['host_name']) ||
	!isset($_GET['event_number']) ||
	!isset($_GET['version']) ||
	!isset($_GET['user_id']) ||
	!isset($_GET['app_token'])
) {
	die('no.');
}

$SECRET_KEY = "COFFEEISGO123123OD_ANDLYFEBLOOD23123123";

$time_stamp = time();
$ab_value = $_GET['is_a'];
$event_value = $_GET['event_value'];
$event_name = $_GET['event_name'];
$event_category = $_GET['event_category'];
$screen_name = $_GET['screen_name'];
$screen_token = $_GET['screen_token'];
$host_name = $_GET['host_name'];
$event_number = $_GET['event_number'];
$game_version = $_GET['version'];
$user_id = $_GET['user_id'];

$app_token = $_GET['app_token'];
$hash = md5($SECRET_KEY . $user_id . $event_number);

if ($app_token != $hash) {
	die('no..');
}

$db = new SqLite3("logging.db");
$db->busyTimeout(25000);
$time_stamp = "'" . $db->escapeString($time_stamp) . "'";
$ab_value = "'" . $db->escapeString($ab_value) . "'";
$event_value = "'" . $db->escapeString($event_value) . "'";
$event_name = "'" . $db->escapeString($event_name) . "'";
$event_category = "'" . $db->escapeString($event_category) . "'";
$screen_name = "'" . $db->escapeString($screen_name) . "'";
$screen_token = "'" . $db->escapeString($screen_token) . "'";
$host_name = "'" . $db->escapeString($host_name) . "'";
$event_number = "'" . $db->escapeString($event_number) . "'";
$game_version = "'" . $db->escapeString($game_version) . "'";
$user_id = "'" . $db->escapeString($user_id) . "'";

$data = implode(',', array(
	$time_stamp,
	$user_id,
	$event_number,
	$host_name,
	$screen_name,
	$event_category,
	$event_name,
	$event_value,
	$screen_token,
	$game_version,
	$ab_value
));

$query = "INSERT INTO all_data (time_stamp, user_id, event_number, host_name, screen_name, event_category, event_name, event_value, screen_token, game_version, ab_value) VALUES  (" . $data . ");";
$sql_return = $db->query($query);
$db->close();
unset($db);
exit();
?>
