_agent.Dispose();
delete _agent;
if (path_exists(_path)) {
	path_delete(_path);
}