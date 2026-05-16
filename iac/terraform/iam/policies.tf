resource "aws_iam_policy" "S3_todo_files_getPutDel" {
  name        = "S3TodoFilesGETPUTDEL"
  description = "Allow services to get/put/del files from S3 for todo app"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect : "Allow",
        Resource : [
          "${var.s3_files_arn}",
          "${var.s3_files_arn}/*"
        ]
      }
    ]
  })
}
