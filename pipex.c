/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aarcos <aarcos@student.42.fr>              #+#  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025-05-16 14:49:40 by aarcos            #+#    #+#             */
/*   Updated: 2025-05-16 14:49:40 by aarcos           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

void	pipex(char **argv, char **envp)
{
	t_pipex	px;
	pid_t	pid1;
	pid_t	pid2;

	px.infile = open(argv[1], O_RDONLY);
	if (px.infile < 0)
		error_exit("Infile error");
	px.outfile = open(argv[4], O_CREAT | O_WRONLY | O_TRUNC, 0644);
	if (px.outfile < 0)
		error_exit("Outfile error");
	if (pipe(px.pipefd) == -1)
		error_exit("Pipe error");
	pid1 = fork();
	if (pid1 == 0)
		child1(argv[2], envp, &px);
	pid2 = fork();
	if (pid2 == 0)
		child2(argv[3], envp, &px);
	close_all(px.infile, px.outfile, px.pipefd);
	waitpid(pid1, NULL, 0);
	waitpid(pid2, NULL, 0);
}

void	child1(char *cmd, char **envp, t_pipex *px)
{
	close(px->outfile);
	close(px->pipefd[0]);
	child_cmd(cmd, envp, px->infile, px->pipefd[1]);
}

void	child2(char *cmd, char **envp, t_pipex *px)
{
	close(px->infile);
	close(px->pipefd[1]);
	child_cmd(cmd, envp, px->pipefd[0], px->outfile);
}

void	close_all(int infile, int outfile, int *pipefd)
{
	close(pipefd[0]);
	close(pipefd[1]);
	close(infile);
	close(outfile);
}
