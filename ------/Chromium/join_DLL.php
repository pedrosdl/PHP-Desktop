<?php
$pasta = dirname(__FILE__)."\\";
for ($i = 1; $i <= 9; $i++) {
	$filename = $pasta.'Chrome.dll.part0'.$i;
	if (file_exists($filename)) {
		echo "Juntando parte ".$i.PHP_EOL;
		$parte[$i] = file_get_contents($filename);
		file_put_contents($pasta."Chrome.dll", $parte[$i], FILE_APPEND | LOCK_EX);
		$parte[$i] = null;
		unlink($filename);
	}
	else {
		break;
	}
}
unlink($pasta.'join_DLL.php');
?>