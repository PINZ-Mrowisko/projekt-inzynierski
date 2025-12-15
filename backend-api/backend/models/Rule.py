class Rule:
    def __init__(self, tags, count):

        self.tags = tags  # List of tag IDs
        self.count = count
        self.type = self.determine_type()

    def determine_type(self):
        tags_list = [tag.strip() for tag in self.tags.split(',')]
        self.tags = tags_list

        if len(tags_list) == 1:
            return 'single_tag'
        else:
            return 'multiple_tags'

    def __str__(self):
        return f"Rule(tags={self.tags}, count={self.count}, type={self.type})"

