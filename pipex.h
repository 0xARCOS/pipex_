/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aarcos <aarcos@student.42.fr>              #+#  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025-05-16 14:49:40 by aarcos            #+#    #+#             */
/*   Updated: 2025-05-16 14:49:40 by aarcos           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_H
# define PIPEX_H

# include <fcntl.h>
# include <stdio.h>
# include <stdlib.h>
# include <sys/wait.h>
# include <unistd.h>

typedef struct s_pipex
{
	int	infile;
	int	outfile;
	int	pipefd[2];
}	t_pipex;

void	pipex(char **argv, char **envp);
void	child_cmd(char *cmd, char **envp, int input_fd, int output_fd);
void	error_exit(const char *msg);
void	close_all(int infile, int outfile, int *pipefd);
void	child1(char *cmd, char **envp, t_pipex *px);
void	child2(char *cmd, char **envp, t_pipex *px);

// Funciones auxiliares que usarás más adelante
char	**ft_split(char const *s, char c);
char	**get_paths_from_envp(char **envp);
char	*join_path_cmd(char *path, char *cmd);

int		ft_strlen(const char *s);
int		ft_strncmp(const char *s1, const char *s2, int n);
char	*ft_strjoin(const char *s1, const char *s2);

#endif
