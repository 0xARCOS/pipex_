#ifndef PIPEX_H
# define PIPEX_H

# include <fcntl.h>
# include <stdio.h>
# include <stdlib.h>
# include <sys/wait.h>
# include <unistd.h>

// Funciones principales
void	pipex(char **argv, char **envp);
void	child_cmd(char *cmd, char **envp, int input_fd, int output_fd);
void	error_exit(const char *msg);
void	close_all(int infile, int outfile, int *pipefd);
void	child1(char *cmd, char **envp, int infile, int *pipefd, int outfile);
void	child2(char *cmd, char **envp, int infile, int *pipefd, int outfile);

// Funciones auxiliares que usarás más adelante
char	**ft_split(char const *s, char c);
char	**get_paths_from_envp(char **envp);
char	*join_path_cmd(char *path, char *cmd);

int		ft_strlen(const char *s);
int		ft_strncmp(const char *s1, const char *s2, int n);
char	*ft_strjoin(const char *s1, const char *s2);

#endif
