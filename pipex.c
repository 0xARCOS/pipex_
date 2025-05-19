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
	int		pipefd[2];
	pid_t	pid1;
	pid_t	pid2;
	int		infile;
	int		outfile;

	infile = open(argv[1], O_RDONLY);
	if (infile < 0)
		error_exit("Infile error");
	outfile = open(argv[4], O_CREAT | O_WRONLY | O_TRUNC, 0644);
	if (outfile < 0)
		error_exit("Outfile error");
	if (pipe(pipefd) == -1)
		error_exit("Pipe error");
	pid1 = fork();
	if (pid1 == 0)
		child1(argv[2], envp, infile, pipefd, outfile);
	pid2 = fork();
	if (pid2 == 0)
		child2(argv[3], envp, infile, pipefd, outfile);
	close_all(infile, outfile, pipefd);
	waitpid(pid1, NULL, 0);
	waitpid(pid2, NULL, 0);
}

void	child1(char *cmd, char **envp, int infile, int *pipefd, int outfile)
{
	close(outfile);
	close(pipefd[0]);
	child_cmd(cmd, envp, infile, pipefd[1]);
}

void	child2(char *cmd, char **envp, int infile, int *pipefd, int outfile)
{
	close(infile);
	close(pipefd[1]);
	child_cmd(cmd, envp, pipefd[0], outfile);
}

void	close_all(int infile, int outfile, int *pipefd)
{
	close(pipefd[0]);
	close(pipefd[1]);
	close(infile);
	close(outfile);
}

