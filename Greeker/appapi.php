<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class appapi extends CI_Controller {

	/**
	 * Index Page for this controller.
	 *
	 * Maps to the following URL
	 * 		http://example.com/index.php/home
	 *	- or -  
	 * 		http://example.com/index.php/home/index
	 *	- or -
	 * Since this controller is set as the default controller in 
	 * config/routes.php, it's displayed at http://example.com/
	 *
	 * So any other public methods not prefixed with an underscore will
	 * map to /index.php/home/<method_name>
	 * @see http://codeigniter.com/user_guide/general/urls.html
	 */
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('model_common', 'm_common');
	}
	
	public function index()
	{
		$data['lastest_user'] = $this->m_common->get_all_lastest_user();
		$data['lastest_city'] = $this->m_common->get_all_lastest_city();
		$data['lastest_school'] = $this->m_common->get_all_lastest_school();
		$data['lastest_organization'] = $this->m_common->get_all_lastest_organization();
		$data['lastest_events'] = $this->m_common->get_all_lastest_events();
		$data['lastest_tasks'] = $this->m_common->get_all_lastest_tasks();
		$data ['current_tab'] = "home";
		$data ['main_page'] = "common/home_view";
		$data['title'] =  common_title;
		$data['function_label'] = common_title;
		$this->load->view('template', $data);
	}
	
	public function getuserinfo($user_id) {
		header('Content-type: text/json');
		echo json_encode($this->get_user_by_id($user_id));
	}
	
	public function updateprofile()
	{
		header('Content-type: text/json');
		$user_id = $this->input->post("user_id");
		if(!$user_id) {
			echo "{\"status\":\"not ok!\"}";
			return;
		}
		$position = $this->input->post("role");
		$pledge_class = $this->input->post("class");
		$major = $this->input->post("major");
		$birthday = $this->input->post("birthday");
		$phone = $this->input->post("phone");
		$email = $this->input->post("email");
		$show_email = $this->input->post("show_email");
		
		$upload_data_photo = $this->file_upload("photo", 0);
		 
		$photo = null;
		 
		if (isset($upload_data_photo['file_path']))
		{
			$photo = $upload_data_photo['file_path'];
		}
		
		$upload_data_banner = $this->file_upload("banner", 0);
			
		$banner = null;
			
		if (isset($upload_data_banner['file_path']))
		{
			$banner = $upload_data_banner['file_path'];
		}
		
		$data = array('position'=> $position, 'pledge_class' => $pledge_class,
				'major' => $major, 'birthday' => $birthday,
				'phone' => $phone, 'email' => $email, 'show_email' => $show_email);
		
		if ($photo) {
			$data['photo'] = $photo;
		}
		
		if ($banner) {
			$data['banner'] = $banner;
		}
		
		$this->db->where('id', $user_id);
		$this->db->update('gre_user',$data);
		
		$result = $this->get_user_by_id($user_id);
		echo json_encode($result);
	}
	
	// hoangnh
	
	public  function create_activity($data)
	{
		$this->db->insert('gre_activity', $data);
	}
	
	public function get_user_by_id($user_id)
	{
		$result = $this->db->select('a.organization_id as org_id, a.request_type, a.approved, b.*, c.name as organization_name, ct.name as city_name')
		->from('gre_user as b')
		->join('gre_organization_user as a', 'a.user_id = b.id', 'left')
        ->join('gre_city as ct', 'b.hometown = ct.id', 'left')
		->join('gre_organization as c', 'c.id = a.organization_id', 'left')
		->where('b.id', $user_id)
		->get()->result_array();
        
        if (count($result))
        {
            // 				$sql = "SELECT organization_id FROM gre_organization_user WHERE user_id=".$result[0]["id"]." AND approved= 1 LIMIT 1";
            // 				$orgid = $db->QuerySingleValue($sql);
            // 				if($orgid!=false)
            // 					$result[0]["org_id"] = $orgid;
            if(!$result[0]['org_id'])
            {
                $result[0]['org_id'] = '0';
                $result[0]['approved'] = '0';
            }
            
            if (!$result[0]['approved'])
            {
                $result[0]['org_id'] = '0';
                $result[0]['approved'] = '0';
            }
            
            return $result[0];
        }else{
            return "{\"message\":\"Your username or password is incorrect\",\"status\":\"0\"}";
        }

// 		echo json_encode($result[0]);
	}
	
	public function searchclub()
	{
		$searchText = $this->input->post("search_text");
		if(!$searchText) {
			echo "{\"status\":\"need search text\"}";
			return;
		}
		
		$result = $this->db->select("a.*, b.name as city_name, c.name as school_name")
		->from('gre_organization as a')
		->join('gre_city as b', 'b.id = a.city', 'left')
		->join('gre_school as c', 'c.id = a.school', 'left')
		->where("a.name like '%".$searchText."%' or b.name like '%".$searchText."%' or c.name like '%".$searchText."%'")
		->get()->result_array();
		echo json_encode($result);
	}
	
	public function searchmember()
	{
		$searchText = $this->input->post("search_text");
		if(!$searchText) {
			echo "{\"status\":\"need search text\"}";
			return;
		}
		$result = $this->db->select("a.*, b.name as city_name, c.name as school_name,d.id as id_of_invite, ou.organization_id as org_id")
		->from('gre_user as a')
		->join('gre_organization_user as ou', 'ou.user_id = a.id', 'left')
		->join('gre_city as b', 'b.id = a.hometown', 'left')
		->join('gre_school as c', 'c.id = a.school', 'left')
		->join('gre_invite_user as d', 'a.id = d.user_id', 'left')
		->where("a.username like '%".$searchText."%' or a.first_name like '%".$searchText."%' or a.last_name like '%".$searchText."%'")
		->get()->result_array();
		echo json_encode($result);
	}
	
	public function save_invite() {
		 
		header('Content-type: text/json');
		 
		$org_id = $this->input->post('org_id');
		$user_id = $this->input->post('user_id');
		$user_invite_id = $this->input->post('user_invite_id');
		$create_time = date('Y-m-d h:i:s', time());
		
		
		// get user infomation
		$user_info =
		$this->db->where('id', $user_id)
		->get('gre_user')->result_array();
		
		$invite_by = $this->db->where('id', $user_invite_id)
		->get('gre_user')->result_array();
		
		$activity = array();
		$activity['title'] = 'Invite ' . $user_info[0]['first_name']. ' ' . $user_info[0]['last_name'] . ' to join';
		$activity['type'] = 0;
		$activity['org_id'] = $org_id;
		$activity['update_time'] = date('Y-m-d H:i:s', time());
		$activity['subtitle'] = 'By ' . $invite_by[0]['first_name'] . ' ' . $invite_by[0]['last_name'];
		
		$this->create_activity($activity);
		// end of activity
		
		
		$this->db->insert('gre_invite_user', array(
				'organization_id' => $org_id,
				'user_id' => $user_id,
				'user_invite_id' => $user_invite_id,
				'create_time' => $create_time
		));
		 
		$insert_id = $this->db->insert_id();
		
		echo "{\"insert_id\":\"" . $insert_id . "\"}";
		
	}
	
	
	public function get_invite_by_user($user_id = 0)
	{
		header('Content-type: text/json');
		$result = $this->db->select('a.*, b.name, c.username, c.photo')
		->from('gre_invite_user as a')
		->join('gre_organization as b', 'a.organization_id = b.id', 'left')
		->join('gre_user as c', 'c.id = a.user_invite_id', 'left')
		->where('a.user_id', $user_id)
		->get()
		->result_array();
		echo json_encode($result);
	}
	//??
	public function processinvite($user_id = 0, $org_id = 0, $accept = 0)
	{
		header('Content-type: text/json');
		
		
		// get user infomation
		$user_info =
		$this->db->where('id', $user_id)
		->get('gre_user')->result_array();
		
		$activity = array();
		
		$activity['type'] = 0;
		$activity['org_id'] = $org_id;
		$activity['update_time'] = date('Y-m-d H:i:s', time());
		if ($accept == 0) {
			$activity['title'] = $user_info[0]['first_name']. ' ' . $user_info[0]['last_name'] . ' rejected to join.';
			$activity['subtitle'] = 'Invitation has been rejected.';
		} else {
			$activity['title'] = $user_info[0]['first_name']. ' ' . $user_info[0]['last_name'] . ' joined club.';
			$activity['subtitle'] = 'Invitation has been accept.';
		}
		
		$this->create_activity($activity);
		// end of activity
		
		$this->db->where('user_id', $user_id);
		if ($accept == 0) {
			$this->db->where('organization_id', $org_id);
		}
		$this->db->delete('gre_invite_user');	
		if ($accept == 0) {
			// reject
			return ;
		} 
		
		$data = array (
			'user_id'=>$user_id,
			'organization_id'=>$org_id,
			'approved'=>1,
			'request_type'=>0
		);
		$this->db->insert('gre_organization_user',$data);
	}
	
	
	public function memberlist()
	{
		$club_id = $this->input->post('club_id');
		if(!$club_id){
			echo "{\"status\": \"please chose club\"}";
		}
		$result = $this->db->select("a.*, b.name as city_name, c.name as school_name, d.*")
		->from('gre_organization_user as a')
		->join('gre_user as d', 'a.user_id = d.id', 'left')
		->join('gre_city as b', 'b.id = d.hometown', 'left')
		->join('gre_school as c', 'c.id = d.school', 'left')
		->where('a.organization_id', $club_id)
		->where('a.approved !=', 0)
		->get()->result_array();
		if(!$result){
			echo "{\"status\":\"No result\"}";
		} else {
			echo json_encode($result);
		}
	}
	
	public function memberprofile()
	{
		$user_id = $this->input->post('user_id');
		if(!$user_id){
			echo "{\"status\": \"please chose user\"}";
		}
		$result = $this->db->select("a.*, b.name as city_name, c.name as school_name")
		->from('gre_user as a')
		->join('gre_city as b', 'b.id = a.hometown', 'left')
		->join('gre_school as c', 'c.id = a.school', 'left')
		->where("a.id", $user_id)
		->get()->result_array();
		if(!$result){
			echo "{\"status\":\"No result\"}";
		} else {
			echo json_encode($result);
		}
		
	}
	
	//gui yeu cau toi bang
	public function sendrequest()
	{
		$user_id = $this->input->post('user_id');
		$request_type = $this->input->post('request_type');
		$org_id = $this->input->post('org_id');
		
		// get user infomation
		$user_info =
		$this->db->where('id', $user_id)
		->get('gre_user')->result_array();
		
		$activity = array();
		$activity['title'] = $user_info[0]['first_name']. ' ' . $user_info[0]['last_name'] . ' has sent request.';
		$activity['type'] = 0;
		$activity['org_id'] = $org_id;
		$activity['update_time'] = date('Y-m-d H:i:s', time());
		if ($request_type == 0)
		{
		$activity['subtitle'] = 'Request as Pledge.';
		} else if ($request_type == 1)
		{
			$activity['subtitle'] = 'Request as Member.';
		} else if ($request_type == 2) {
			
			$activity['subtitle'] = 'Request as Admin.';
		}
		
		$this->create_activity($activity);
		
			
		//check xem co hay chua
		$result = $this->db->where("user_id", $user_id)
		->where("organization_id", $org_id)
		->get("gre_organization_user")->result_array();
		
		if (!count($result)){
			echo "{\"status\": \"no result\"}";
			$data = array(
				"user_id"=>$user_id,
				"organization_id"=>$org_id,
				"approved"=>'0',
				"request_type"=>'0'
					);
			$this->db->insert("gre_organization_user", $data);
			echo "{\"status\": \"insert request success\"}";
		} else {
		
			//neu co request_type thi check xem la gui lai hay gui moi
			//check request.(neu da gui thi bao da gui, neu request cao hon thi update)
				$data['request_type'] = $request_type;
				$this->db->where("user_id", $user_id)
				->where("organization_id", $org_id)
				->update("gre_organization_user",$data);
				echo "{\"status\": \"update request success\"}";
		}
		
		
	}
	//hien thi moi yeu cau de xu li
	public function showallrequest($org_id)
	{
		header('Content-type: text/json');
		//$organization_id = $this->input->post('organization_id');
		
		if(!$org_id){
			echo "{\"status\": \"please chose organization\"}";
		}
		$result = $this->db->select("a.*, b.first_name as first_name, b.last_name as last_name")
		->from("gre_organization_user as a")
		->join("gre_user as b", 'a.user_id = b.id', 'left')
		->where("a.organization_id", $org_id)
		->where("(a.request_type + 1) > a.approved")
		->get()->result_array();
		
			echo json_encode($result);
		
		
	}
	
	//xu li yeu cau gia nhap (loai bo doi tuong, chap nhan, bo qua yeu cau)
	public function processRequest($org_id, $user_id, $process){
		header('Content-type: text/json');
		// org_id
		
		// lay ra reqeust day theo user_id, org_id
		$res = $this->db->where("user_id", $user_id)
		->where("organization_id", $org_id)
		->get("gre_organization_user")->result_array();
		// count = 0 bao loi
		$request_type = '';
		if(!count($res)){
			//echo "{\"status\": \"no request for process\"}";
		} else {
			$res = $res[0];
			$request_type = $res['request_type'];
			if($process == 1){
				$data['approved'] = $res['approved'] + 1;
				$this->db->where("id", $res['id'])->update("gre_organization_user", $data);
				//xoa cac record khac voi org id khac
				$this->db->where("user_id", $user_id)
				->where("organization_id !=", $org_id)->delete("gre_organization_user");
			} else {
				if ($res['request_type'] > 0){
				$data['request_type'] = $res['request_type'] - 1;
				$this->db->where("id", $res['id'])->update("gre_organization_user", $data);
				} else {
					$this->db->where("user_id", $user_id)
					->where("organization_id", $org_id)->delete("gre_organization_user");
				}
				//neu request_type = 0 thi xoa record do di.( tai org_id va user_id); 
			}
		}
		
		// get user infomation
		$user_info = $this->get_user_by_id($user_id);
		
		$activity = array();
		if ($process == 1) {
			$activity['subtitle'] = $user_info['first_name']. ' ' . $user_info['last_name']. '\'s request has been approved.';
			$activity['title'] = 'Request approved';
		} else {
			$activity['subtitle'] = $user_info['first_name']. ' ' . $user_info['last_name']. '\'s request has been rejected.';
			$activity['title'] = 'Request rejected';
		}
		$activity['type'] = 0;
		$activity['org_id'] = $org_id;
		$activity['update_time'] = date('Y-m-d H:i:s', time());
		
		
		
		/*
		if ($request_type == 0)
		{
			$activity['subtitle'] = 'Request as Pledge.';
		} else if ($request_type == 1)
		{
			$activity['subtitle'] = 'Request as Member.';
		} else if ($request_type == 2) {
				
			$activity['subtitle'] = 'Request as Admin.';
		}
		*/
		
		$this->create_activity($activity);
		
		$this->showallrequest($org_id);
	}
	
	
	//update infomation club
	public function updateclub(){
		header('Content-type: text/json');
		//check name
		$org_id = $this->input->post('org_id');
		$name = trim($this->input->post('name'));
		
		
		
		
		$validate_name = $this->db->where('name', $name)->where('id !=', $org_id)->get('gre_organization')->result_array();
		if(count($validate_name)){
			echo "{\"status\": \"this name is existed\"}";
		} else {
			$data = array();
			
			$upload_data_photo = $this->file_upload("photo", 0);
				
			$photo = null;
				
			if (isset($upload_data_photo['file_path']))
			{
				$photo = $upload_data_photo['file_path'];
			}
			
			if($photo) {
				$data['logo'] = $photo;
			}
			
			$introduction = trim($this->input->post('introduction'));
			if ($introduction) {
				$data['introduction'] = $introduction;
			}
			$letters = trim($this->input->post('letters'));
			if ($letters) {
				$data['letters'] = $letters;
			}
			$school = trim($this->input->post('school'));
			if ($school) {
				$data['school'] = $school;
			}
			$city = trim($this->input->post('city'));
			if ($city) {
				$data['city'] = $city;
			}
			$chapter = trim($this->input->post('chapter'));
			if ($chapter) {
				$data['chapter'] = $chapter;
			}
			$this->db->where("id", $org_id)->update("gre_organization", $data);
			echo json_encode($data);
		}
		
	}
	//get task by org
	public function tasklist ($org_id = 0, $user_id = 0){
		header('Content-type: text/json');
		//neu la admin thi get all. 
		// delete all complete task before today
		
		
		
		$this->db->where('organization_id', $org_id)
		->where('status', 2)
		->where('complete_date <', date("Y-m-d H:i:s", strtotime( '-1 days' )))
		->delete('gre_task');
		
		//neu la member or pledge thi get task for everyone and pledge + cho chinh no
		if (!$org_id){
			echo "{\"status\": \"please chose organization\"}";
		} else {
			$res = 
			$this->db->where("organization_id", $org_id)
			->limit(40)
			->order_by("status")
			->order_by("due_date", "desc")
			->get('gre_task')->result_array();
			if(!count($res)){
				echo json_encode($res);
			} else {
				$task_list = array();
				foreach ($res as $task){
// 					echo json_encode($res);
					$result = $this->db->select("a.*, b.first_name, b.last_name")
					->from("gre_task_user as a")
					->join("gre_user as b", "a.user_id = b.id", "left")
					->where('a.task_id', $task['id'])
					->get()->result_array();
					$task['user_on_it'] = $result;
					$task_list[] = $task;
				}
				echo json_encode($task_list);
			}
		}
	}
	//club info
	public function orginfo($org_id){
		header('Content-type: text/json');
		$res = $this->db->where('id', $org_id)
		->where('valid', 1)
		->get('gre_organization')->result_array();
		if(!count($res)){
			echo "{\"status\": \"no exist organization\"}";
		} else {
			echo json_encode($res);
		}
	}
	
	//set task assign
	public function taskassign($task_id, $user_id){
		//check exist
		header('Content-type: text/json');
		$data = array(
				'task_id'=>$task_id,
				'user_id'=>$user_id
				);
		$data_task = array();
		$res = 
		$this->db->where("task_id", $task_id)
		->where("user_id", $user_id)
		->get('gre_task_user')
		->result_array();
		if (count($res)){
			echo "{\"status\": \"this task assigned\"}";
		} else {
			$this->db->insert("gre_task_user", $data);
			$data_task['status'] = 1;
			$this->db->where("id", $task_id)
			->update("gre_task", $data_task);
			
			
			// get user infomation
			$user_info = $this->get_user_by_id($user_id);
			$res = $this->db->where("id", $task_id)->get("gre_task")->result_array();
			
			
			$activity = array();
			$activity['type'] = 1;
			$activity['org_id'] = $res[0]['organization_id'];
			$activity['update_time'] = date('Y-m-d H:i:s', time());
				
			$activity['title'] = $res[0]['title'];
			$activity['subtitle'] = $user_info['first_name']. ' on it!';
				
			$this->create_activity($activity);
			// end of activity
			
			echo "{\"status\": \"Task assigned ok\"}";
		}
	}
	//set task complete
	public function taskcomplete($task_id){
		header('Content-type: text/json');
		
		$data = array(
				'complete_date'=>date('Y-m-d', time()),
				'complete_time'=>date('H:i:s', time())
				);
		$res = $this->db->where("id", $task_id)->get("gre_task")->result_array();
		if(!count($res)){
			echo "{\"status\": \"task_id not found.\"}";
		} else {
			$data['status'] = 2;
			$this->db->where("id", $task_id)->update("gre_task", $data);
			// get user infomation
			
			$activity = array();
			$activity['type'] = 1;
			$activity['org_id'] = $res[0]['organization_id'];
			$activity['update_time'] = date('Y-m-d H:i:s', time());
			
			$activity['title'] = $res[0]['title'];
			$activity['subtitle'] = 'Task completed';
			
			$this->create_activity($activity);
			// end of activity
			
			echo "{\"status\": \"OK. task is updated\"}";
		}
	}
	
	// create task
	public function createtask()
	{
		
		
		header('Content-type: text/json');
		$org_id = $this->input->post('org_id');
		$task_title = $this->input->post('task_title');
		$task_date = $this->input->post('task_date');
		$task_time = $this->input->post('task_time');
		$task_location = $this->input->post('task_location');
		$task_detail = $this->input->post('task_detail');
		
		
		// get user infomation
		
		$activity = array();
		
		$activity['type'] = 1;
		$activity['org_id'] = $org_id;
		$activity['update_time'] = date('Y-m-d H:i:s', time());
		
		$activity['title'] = $task_title;
		$activity['subtitle'] = 'Task created';
		
		$this->create_activity($activity);
		// end of activity
		
		$data = array(
				'organization_id' => $org_id,
				'title' => $task_title,
				'location' => $task_location,
				'due_date' => $task_date,
				'detail' => $task_detail,
				'due_time' => $task_time
		);
		$this->db->insert('gre_task', $data);
		echo "{\"status\": \"Task create success!.\"}";
		
	}
	
	
	public function leaveclub(){
		//check name
		header('Content-type: text/json');
		$user_id = $this->input->post('user_id');
		$org_id = trim($this->input->post('org_id'));
		// check admin user
		
		// count all member in club
		
		$count_all_member = $this->db->where('organization_id', $org_id)
		->where('approved >', 0)
		->count_all_results('gre_organization_user');
		
		if($count_all_member == 1) {
			// delete club
			$this->db->where('organization_id', $org_id)
			->delete('gre_organization_user');
			
			$this->db->where('id', $org_id)
			->delete('gre_organization');
			echo "{\"message\":\"Leave success!\". $user_id. 'org'. $org_id,\"status\":\"1\"}";
			return;
		}
		
		
		$result = $this->get_user_by_id($user_id);
		if ($result['approved'] == 3) {
			$total_admin = $this->get_all_total_admin($org_id);
			if ($total_admin <= 1) {
				echo "{\"error_message\":\"Can't not leave club!\"}";
				return ;
			}
		}
		
		// get user infomation
		$user_info = $this->get_user_by_id($user_id);
		
		$activity = array();
		
		$activity['type'] = 0;
		$activity['org_id'] = $org_id;
		$activity['update_time'] = date('Y-m-d H:i:s', time());
		
		$activity['title'] = $user_info['first_name']. ' ' . $user_info['last_name'] . ' has left Club.';
		$activity['subtitle'] = 'Member leave Club';
		
		$this->create_activity($activity);
		// end of activity
		
			$this->db->where("user_id", $user_id)
			->where('organization_id', $org_id)
			->delete('gre_organization_user');

			echo "{\"message\":\"Leave success!\". $user_id. 'org'. $org_id,\"status\":\"1\"}";
	}
	
	function get_all_total_admin($org_id = 0) {
		$result = $this->db->select('a.organization_id as org_id, a.request_type, a.approved, b.*, c.name as organization_name')
		->from('gre_user as b')
		->join('gre_organization_user as a', 'a.user_id = b.id', 'left')
		->join('gre_organization as c', 'c.id = a.organization_id', 'left')
		->where('a.organization_id', $org_id)
		->where('a.approved',3)
		->count_all_results();
		return $result;
	}
	
	// activities
	
	public function activities ($org_id = 0)
	{
		header('Content-type: text/json');
		$res = $this->db->where('org_id', $org_id)
		->order_by('update_time', 'desc')
		->limit(20)
		->get('gre_activity')
		->result_array();
		echo json_encode($res);	
	}
	
	public function signup()
	{
		
		header('Content-type: text/json');
		
		$username  = $this->input->post("username");
		if($this->input->post("password"))
		{
			$password =  md5($this->input->post("password"));
		} else {
			$password =  md5(time());	
		}
	
		//$password  = isset($this->input->post("password")) ? md5($this->input->post("password")) : md5(time());
		$firstname = $this->input->post("firstname");
		$lastname  = $this->input->post("lastname");
		
		$birthday  = $this->input->post("birthday");
		$email     = $this->input->post("email");
		$photo     = $this->input->post("photo");
		$gender    = $this->input->post("gender");
		$facebook  = $this->input->post("facebook");
		$school    = $this->input->post("school");
		$org       = $this->input->post("org");
		$hometown  = $this->input->post("hometown");
		$position  = $this->input->post("position");
		$major     = $this->input->post("major");
		$pledge  = $this->input->post("pledge");
        $phone  = $this->input->post("phone");
		
		$city_id = 0;
		$school_id = 0;
		// check school and city
		$cities = $this->db->where('name', $hometown)
		->get('gre_city')
		->result_array();
		if(count($cities)) {
			$city_id = $cities[0]['id'];
		} else {
			if(!$hometown) {
			$this->db->insert('gre_city', array('name' => $hometown, 'create_by' => 1, 'update_by' => 1, 'create_time' => date('Y-m-d H:i:s', time()), 'update_time' => date('Y-m-d H:i:s', time()), 'valid' => 1));
			$city_id = $this->db->insert_id();
			}
		}
		
		
		// check school and city
		$schools = $this->db->where('name', $school)
		->get('gre_school')
		->result_array();
		if(count($schools)) {
			$school_id = $schools[0]['id'];
		} else {
			if(!$school) {
			$this->db->insert('gre_school', array('name' => $school, 'create_by' => 1, 'update_by' => 1, 'create_time' => date('Y-m-d H:i:s', time()), 'update_time' => date('Y-m-d H:i:s', time()), 'valid' => 1));
			$school_id = $this->db->insert_id();
			}
		}
		
		if(!$position) {
			$position = "N/A";
		}
		
		if (!$major) {
			$major = "N/A";
		}
		
		if(!$pledge)
		{
			$pledge = "A";
		}
		
		
		$users = $this->db->where('username', $username)
		->get('gre_user')
		->result_array();
		
		if(!count($users)) {
			$data = array(
					'username' => $username,
					'password' => $password,
					'first_name' => $firstname,
					'last_name' => $lastname,
					'email' => $email,
					'photo' => $photo,
					'facebook' => $facebook,
					'birthday' => $birthday,
					'sex' => $gender,
					'school' => $school_id,
					'pledge_class' => $pledge,
					'hometown' => $city_id,
					'position' => $position,
					'major' => $major,
                    'phone' => $phone
			);
			
			$this->db->insert('gre_user', $data);
			$insert_id = $this->db->insert_id();
			if($org>0){
				$org_data = array(
					'user_id' => $insert_id,
					'organization_id' => $org,
					'approved' => 0	
				);
				$this->db->insert('gre_organization_user', $org_data);
			//	$sql = "INSERT INTO gre_organization_user(user_id,organization_id,approved) VALUES('".$result[0]["id"]."',$org,0)";
			//	$db->Query($sql);
			}
			
			if(empty($facebook)){
				echo "{\"message\":\"Your profile is ready now, please comeback to login\",\"status\":\"1\"}";
				exit;
			} else {
				$result = $this->db->select('a.organization_id as org_id, a.request_type, a.approved, b.*, c.name as organization_name')
				->from('gre_user as b')
				->join('gre_organization_user as a', 'a.user_id = b.id', 'left')
				->join('gre_organization as c', 'c.id = a.organization_id', 'left')
				->where('b.username',$username)
				//->where('a.approved >', 0)
				->get()->result_array();
					
				//$sql = "SELECT * FROM gre_user WHERE username='$username'AND password = '$password'";
				//$result = $db->QueryArray($sql, MYSQL_ASSOC);
				if (count($result))
				{
					// 				$sql = "SELECT organization_id FROM gre_organization_user WHERE user_id=".$result[0]["id"]." AND approved= 1 LIMIT 1";
					// 				$orgid = $db->QuerySingleValue($sql);
					// 				if($orgid!=false)
					// 					$result[0]["org_id"] = $orgid;
					if(!$result[0]['org_id'])
					{
						$result[0]['org_id'] = '0';
						$result[0]['approved'] = '0';
					}
					echo json_encode($result);
					return;
				} else {
					echo "{\"message\":\"Your username or password is incorrect\",\"status\":\"0\"}";
					return;
				}
			}
			
		} else {
			if(empty($facebook)){
				echo "{\"message\":\"Username is existed, please choose another username\",\"status\":\"0\"}";
				exit;
			}
			
				$result = $this->db->select('a.organization_id as org_id, a.request_type, a.approved, b.*, c.name as organization_name')
					->from('gre_user as b')
					->join('gre_organization_user as a', 'a.user_id = b.id', 'left')
					->join('gre_organization as c', 'c.id = a.organization_id', 'left')
					->where('b.username',$username)
					//->where('a.approved >', 0)
					->get()->result_array();
					
					if (count($result))
					{

						if(!$result[0]['org_id'])
						{
							$result[0]['org_id'] = '0'; 
							$result[0]['approved'] = '0';
						}
						echo json_encode($result);
						return;
					}else{
						echo "{\"message\":\"Your username or password is incorrect\",\"status\":\"0\"}";
						return;
					}
		}
		
		echo json_encode($users[0]);
	}
	
	public function login()
	{
			header('Content-type: text/json');

			$username  = $this->input->post("username");
			$pass = $this->input->post("password");
// 			$username = 'henry';
// 			$pass = '123';
			$password  = $pass ? md5($pass) : "";
			
			$result = $this->db->select('a.organization_id as org_id, a.request_type, a.approved, b.*, c.name as organization_name')
			->from('gre_user as b')
			->join('gre_organization_user as a', 'a.user_id = b.id', 'left')
			->join('gre_organization as c', 'c.id = a.organization_id', 'left')
			->where('b.username',$username)
			->where('b.password', $password)
			//->where('a.approved >', 0)
			->get()->result_array();
			
			//$sql = "SELECT * FROM gre_user WHERE username='$username'AND password = '$password'";
			//$result = $db->QueryArray($sql, MYSQL_ASSOC);
			if (count($result))
			{
// 				$sql = "SELECT organization_id FROM gre_organization_user WHERE user_id=".$result[0]["id"]." AND approved= 1 LIMIT 1";
// 				$orgid = $db->QuerySingleValue($sql);
// 				if($orgid!=false)
// 					$result[0]["org_id"] = $orgid;
				if(!$result[0]['org_id'])
				{
					$result[0]['org_id'] = '0'; 
					$result[0]['approved'] = '0';
				}
                
                if (!$result[0]['approved'])
                {
                    $result[0]['org_id'] = '0';
                    $result[0]['approved'] = '0';
                }
                
				echo json_encode($result);
				return;
			}else{
				echo "{\"message\":\"Your username or password is incorrect\",\"status\":\"0\"}";
				return;
			}
	}
	
	public function fblogin() {
		header('Content-type: text/json');
		
		$username  = $this->input->post("username");			
		$result = $this->db->select('a.organization_id as org_id, a.request_type, a.approved, b.*, c.name as organization_name')
		->from('gre_user as b')
		->join('gre_organization_user as a', 'a.user_id = b.id', 'left')
		->join('gre_organization as c', 'c.id = a.organization_id', 'left')
		->where('b.username',$username)
		->where('b.password', $password)
		//->where('a.approved >', 0)
		->get()->result_array();
			
		//$sql = "SELECT * FROM gre_user WHERE username='$username'AND password = '$password'";
		//$result = $db->QueryArray($sql, MYSQL_ASSOC);
		if (count($result))
		{
			// 				$sql = "SELECT organization_id FROM gre_organization_user WHERE user_id=".$result[0]["id"]." AND approved= 1 LIMIT 1";
			// 				$orgid = $db->QuerySingleValue($sql);
			// 				if($orgid!=false)
				// 					$result[0]["org_id"] = $orgid;
			if(!$result[0]['org_id'])
			{
				$result[0]['org_id'] = '0';
				$result[0]['approved'] = '0';
			}
			echo json_encode($result);
			return;
		}else{
			echo "{\"message\":\"Your username or password is incorrect\",\"status\":\"0\"}";
			return;
		}
	}
	
	public function updatelocation()
	{
	
		header('Content-type: text/json');
		$user_id = $this->input->post("user_id");
		$long = $this->input->post('long');
		$lat = $this->input->post('lat');
		
		$this->db->where('id', $user_id)
		->update('gre_user', array('long'=>$long, 'lat'=>$lat));
		echo "{\"message\":\"Updating ok\"}";
	}
	
	public function changesharelocation()
	{
	
		header('Content-type: text/json');
		$user_id = $this->input->post("user_id");
		$share_location = $this->input->post('share_location');
	
		$this->db->where('id', $user_id)
		->update('gre_user', array('share_location'=>$share_location));
		echo "{\"message\":\"Updating ok\"}";
	}
	
    // message chat
    public function messagelist() {
    	
    	header('Content-type: text/json');
    	$last_update_time = $this->input->post('last_update_time');
    	$org_id = $this->input->post('org_id');
    	$user_id = $this->input->post('user_id');
    	$message_type = $this->input->post('message_type');

    	// test
//     	$org_id = "2";
//     	$user_id = "19";
//     	$message_type = "0";
    	
    	$this->db->select('a.*, b.username as username, b.photo as user_photo')
    	->from('gre_chat_message as a')
    	->join('gre_user as b', 'a.user_id = b.id', 'left')
    	->where('a.message_type', $message_type)
    	->where('a.organization_id', $org_id);
    	
    	if ($last_update_time) {
    		$this->db->where('a.create_time >',$last_update_time) ;
    		$this->db->where('a.user_id !=',$user_id);
    	}
    	
    	$result = 
    	$this->db->order_by('a.id', 'desc')
    	->limit('30')
    	->get()
    	->result_array();
    	//var_dump($result);
    	//die();
    	
    	if (count($result)) {
    		$last_update_time = $result[0]['create_time'];
    	}
    	$return_data = array('last_update_time' => $last_update_time, 'message_list' => $result);
    	echo json_encode($return_data);
    }
    
    
    public function save_message() {
    	
    	header('Content-type: text/json');
    	
    	$org_id = $this->input->post('org_id');
    	$user_id = $this->input->post('user_id');
    	$message_text = $this->input->post('message_text');
    	$message_type = $this->input->post('message_type');
    	$create_time = date('Y-m-d h:i:s', time());
    	
    	
    	$upload_data = $this->file_upload("image", 0);
    	
    	$image = "";
    	
    	if (isset($upload_data['file_path']))
    	{
    		$image = $upload_data['file_path'];
    	}
    	
    	$this->db->insert('gre_chat_message', array(
    			'organization_id' => $org_id,
    			'user_id' => $user_id,
    			'message_type' => $message_type,
    			'message' => $message_text,
    			'create_time' => $create_time,
    			'image' => $image
    	));
    	
    	$insert_id = $this->db->insert_id();
    	
    	
    	$result = $this->db->select('a.*, b.username as username, b.photo as user_photo')
    	->from('gre_chat_message as a')
    	->join('gre_user as b', 'a.user_id = b.id', 'left')
    	->where('a.message_type', $message_type)
    	->where('a.organization_id', $org_id)
    	 ->where('a.id', $insert_id)
    	->order_by('a.id', 'desc')
    	->get()
    	->result_array();
    	
    	echo json_encode($result[0]);
    	
    	/*
    	$result = $this->db->where('id', $insert_id)
    	->get('gre_chat_message')
    	->result_array();
    	
    	echo json_encode($result);
    	*/
    }
	
	
	
	public function newchapter()
	{
		
		header('Content-type: text/json');
		
		$name = $this->input->post('name');
		$letters = $this->input->post('letters');
		$school = $this->input->post('school');
		$datefounded = $this->input->post('date_founded');
		$city = $this->input->post('city');
		$user_id = $this->input->post('user_id');
		
		$city_id = 0;
		$school_id = 0;
		// check school and city
		$cities = $this->db->where('name', $city)
		->get('gre_city')
		->result_array();
		if(count($cities)) {
			$city_id = $cities[0]['id'];
		} else {
			$this->db->insert('gre_city', array('name' => $city, 'create_by' => 1, 'update_by' => 1, 'create_time' => date('Y-m-d H:i:s', time()), 'update_time' => date('Y-m-d H:i:s', time()), 'valid' => 1));
			$city_id = $this->db->insert_id();
		}
		
		// check school and city
		$schools = $this->db->where('name', $school)
		->get('gre_school')
		->result_array();
		if(count($schools)) {
			$school_id = $schools[0]['id'];
		} else {
			$this->db->insert('gre_school', array('name' => $school, 'create_by' => 1, 'update_by' => 1, 'create_time' => date('Y-m-d H:i:s', time()), 'update_time' => date('Y-m-d H:i:s', time()), 'valid' => 1));
			$school_id = $this->db->insert_id();
		}
		
		
		
		
		$upload_data = $this->file_upload("image", 0);
		
		$logo = "";
		
		if (isset($upload_data['file_path']))
		{
			$logo = $upload_data['file_path'];
		}
			
		
		$res = $this->db->where('name', $name)
		->get('gre_organization')
		->result_array();
		
		
		
		if(count($res))
		{
			echo "{\"error_status\":\"Chapter name already exist!\"}";
			return;
		}	
		$this->db->insert('gre_organization', array('name' => $name,
				'letters' => $letters,
				'school' => $school_id,
				'city' => $city_id,
				'founded_date' => $datefounded,
				'logo' => $logo
		));
		$org_id = $this->db->insert_id();
		
		$this->db->insert('gre_organization_user', array(
				'user_id' => $user_id,
				'organization_id' => $org_id,
				'approved' => 3
		));
		
		$this->db->where('user_id', $user_id)
		->where('approved', 0)
		->delete('gre_organization_user');
		
		$result = $this->db->select('a.organization_id as org_id, a.request_type, a.approved, b.*, c.name as organization_name')
			->from('gre_user as b')
			->join('gre_organization_user as a', 'a.user_id = b.id', 'left')
			->join('gre_organization as c', 'c.id = a.organization_id', 'left')
			->where('b.id', $user_id)
			//->where('a.approved >', 0)
			->get()->result_array();
		if(count($result))
		{
			echo json_encode($result[0]);
		} else {
			echo "{\"error_status\":\"no result!\"}";
		}
		
	}
	
	function file_upload($name, $i=0){
		
		if(!isset($_FILES [$name])){
			return array('message'=> 'Do not upload image!');	
		}
		$file_name = url_title (loc_dau_tv($_FILES [$name] ['name'][$i]), 'dash', true );

		//log_message('error', 'filename:.'.$file_name);
		
		$config['upload_path'] = 'upload/ios/';

		$config['allowed_types'] = 'jpg|png|gif|JPG|PNG|GIF|ico';

		$config['max_size']	= '100000';
		
		$random = rand(0, 10000000);
		
		$config['file_name']	= $random.'-'.$file_name;
		$this->upload->initialize($config);
		
		if(!is_dir('upload/ios/')){
			mkdir('upload/ios/');
		}
		if (!$this->upload->do_upload($name, $i)){
			return array('message'=>$this->upload->display_errors('<p>', '</p>'));
		}else {
			return array('file_path'=>$config['upload_path'].$config['file_name']);
		}
	}
	
	// Event API
	
	function get_events($org_id, $month, $year)
	{
		header('Content-type: text/json');		

			
		$start_of_month = date($year."-".$month."-01");
		$start_next_month = date("Y-m-d", strtotime($start_of_month . " +1 month"));
		$res =
		$this->db->where('due_date >=', $start_of_month )
		->where('due_date <', $start_next_month)
		->where('org_id', $org_id)
		->order_by('due_date')
		->get('gre_event')
		->result_array();
		foreach ($res as $index => $event) {
			$member = $this->db->select('a.*, b.first_name, b.last_name, b.photo')
			->from('gre_event_user as a')
			->join('gre_user as b', 'a.user_id = b.id', 'left')
			->where('a.event_id', $event['id'])
			->get()->result_array();
			$res[$index]['going'] = $member;
		}
		
		echo json_encode($res);
	}
	
	function get_event_info($event_id)
	{
		header('Content-type: text/json');
		$res = $this->db->where('id', $event_id)
		->get('gre_event')
		->result_array();

		echo json_encode($res[0]);
	}
	
	function create_event()
	{
		header('Content-type: text/json');
		$org_id = $this->input->post('org_id');
		$due_date = $this->input->post('due_date');
		$due_time = $this->input->post('due_time');
		$title = $this->input->post('title');
		$location = $this->input->post('location');
		$create_by = $this->input->post('user_id');
		$detail = $this->input->post('detail');
		
		
		// get user infomation
		//$user_info = $this->get_user_by_id($user_id);
		
		$activity = array();
		$activity['type'] = 2;
		$activity['org_id'] = $org_id;
		$activity['update_time'] = date('Y-m-d H:i:s', time());
		$activity['title'] = 'Event created: ' . $title;
		$activity['subtitle'] = 'Due date:' . date("M d, Y", strtotime('Y-m-d', $due_date));
		$this->create_activity($activity);
		// end of activity
		
		$upload_data = $this->file_upload("image", 0);
		
		$logo = "";
		
		if (isset($upload_data['file_path']))
		{
			$logo = $upload_data['file_path'];
		}
		
		$data = array(
				'org_id' => $org_id,
				'due_date' => $due_date,
				'due_time' => $due_time,
				'title' => $title,
				'location' => $location,
				'create_by' => $create_by,
				'update_by' => $create_by,
				'detail' => $detail,
				'image' => $logo,
				'create_time' => time('Y-m-d H:i:s', time()),
				'update_time' => time('Y-m-d H:i:s', time())
		);
		
		$this->db->insert('gre_event', $data);
		
		echo "{\"status\":\"Create event successful!\"}";
	}
	
	
	function going($event_id, $user_id)
	{
		header('Content-type: text/json');
		
		$event_detail = $this->db->where('id', $event_id)
		->get('gre_event')
		->result_array();
		
		$res = $this->db->where('event_id', $event_id)
		->where('user_id', $user_id)
		->get('gre_event_user')
		->result_array();
		
		
		
		if(count($res)) {
			$this->db->where('event_id', $event_id)
			->where('user_id', $user_id)
			->delete('gre_event_user');
			// get user infomation
			$user_info = $this->get_user_by_id($user_id);
			$activity = array();
			$activity['type'] = 2;
			$activity['org_id'] =  $event_detail[0]['org_id'];
			$activity['title'] = 'Event: ' . $user_info['first_name'].' rejected to go';
			$activity['update_time'] = date('Y-m-d H:i:s', time());
			//$activity['title'] = 'Event created: ' . $title;
			$activity['subtitle'] =  $event_detail[0]['title'];
			$this->create_activity($activity);
			// end of activity
		} else {
			$this->db->insert('gre_event_user', array('user_id'=>$user_id, 'event_id'=> $event_id));
			// get user infomation
			$user_info = $this->get_user_by_id($user_id);
			$activity = array();
			$activity['type'] = 2;
			$activity['org_id'] =  $event_detail[0]['org_id'];
			$activity['title'] = 'Event: ' . $user_info['first_name'].' confirmed to go.';
			$activity['update_time'] = date('Y-m-d H:i:s', time());
			//$activity['title'] = 'Event created: ' . $title;
			$activity['subtitle'] =  $event_detail[0]['title'];
			$this->create_activity($activity);
			// end of activity
		}
		
		
		
		echo "{\"status\":\"Going successful!\"}";
	}


	function lookup_chapter() {
		header('Content-type: text/json');

		
		$searchText = $this->input->post('textSearch');
		$textSchool = $this->input->post('textSchool');
		$textCity = $this->input->post('textCity');
		
		
		$result = $this->db->select("a.*, b.name as city_name, c.name as school_name")
		->from('gre_organization as a')
		->join('gre_city as b', 'b.id = a.city', 'left')
		->join('gre_school as c', 'c.id = a.school', 'left')
		
		->where("a.name like '%".$searchText."%'")
		->where("b.name like '%".$textCity."%'")
		->where("c.name like '%".$textSchool."%'")
		->get()->result_array();
		echo json_encode($result);
		
		
		
		// $sql = "SELECT o.*, s.name as schoolname FROM gre_organization o INNER JOIN gre_school s ON o.school=s.id WHERE o.name LIKE '%$name%'";
		// $result = $db->QueryArray($sql, MYSQL_ASSOC);
    	// echo json_encode($result);
	}
	
}
	