char *rl_readline_name = 0;
int rl_insert(int count, int key) { (void) count; (void) key; return 0; }
int rl_bind_key(int key, int (*fn)(int, int)) { (void) key; (void) fn; return 0; }
char *readline(const char *prompt) { (void) prompt; return 0; }
void add_history(const char *line) { (void) line; }
